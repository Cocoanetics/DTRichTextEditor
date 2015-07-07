//
//  DTMutableCoreTextLayoutFrame.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/23/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>

#import "DTMutableCoreTextLayoutFrame.h"
#import "DTRichTextCategories.h"
#import "DTCoreTextLayoutFrame+DTRichText.h"

@implementation DTMutableCoreTextLayoutFrame
{
	NSRange _cachedSelectionRectanglesRange;
	NSArray *_cachedSelectionRectangles;
	
	UIEdgeInsets _edgeInsets; // space between frame edges and text
	BOOL shouldRebuildLines;
	
	// concurrent queue for syncing drawing and updates
	dispatch_queue_t _syncQueue;
}


@synthesize shouldRebuildLines;

- (id)initWithFrame:(CGRect)frame attributedString:(NSAttributedString *)attributedString
{
	self = [super init];
	
	shouldRebuildLines =  YES;
	
	if (self)
	{
		_frame = frame;
		
		if (!attributedString)
		{
			_attributedStringFragment = [[NSMutableAttributedString alloc] initWithString:@""];
		}
		else
		{
			_attributedStringFragment = [attributedString mutableCopy];
		}
		
		_syncQueue = dispatch_queue_create("DTMutableCoreTextLayoutFrame Sync Queue", DISPATCH_QUEUE_CONCURRENT);
		
		// we don't need a layouter because we create a temporary one if we need it
	}
	
	return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
	dispatch_release(_syncQueue);
#endif
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (attributedString != _attributedStringFragment)
	{
		_attributedStringFragment = [attributedString mutableCopy];
		
		[self relayoutText];
	}
}

- (void)relayoutText
{
	dispatch_barrier_sync(_syncQueue, ^{
		
		// next call needs new selection rectangles
		_cachedSelectionRectangles = nil;
		
		// layout the new text
		DTCoreTextLayouter *tmpLayouter = [[DTCoreTextLayouter alloc] initWithAttributedString:_attributedStringFragment];
		CGRect rect = _frame;
		rect.size.height = CGFLOAT_HEIGHT_UNKNOWN;
		NSRange allTextRange = NSMakeRange(0, 0);
		DTCoreTextLayoutFrame *tmpFrame = [tmpLayouter layoutFrameWithRect:rect range:allTextRange];
		
		// transfer the lines
		_lines = [tmpFrame.lines copy];
		
		// correct the overall frame size
		DTCoreTextLayoutLine *lastLine = [_lines lastObject];
		_frame.size.height = ceilf((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5));
		
		// some attachments might have been overwritten, so we force refresh of the attachments list
		_textAttachments = nil;
	});
}

- (void)relayoutTextInRange:(NSRange)range
{
	// that's the full paragraphs that are "dirty"
	NSRange dirtyParagraphRange = [[_attributedStringFragment string] rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	// layout the new paragraph text
	DTCoreTextLayouter *tmpLayouter = [[DTCoreTextLayouter alloc] initWithAttributedString:_attributedStringFragment];
	
	// same rect as self, but open height
	CGRect rect = self.frame;
	rect.size.height = CGFLOAT_HEIGHT_UNKNOWN;
	
	DTCoreTextLayoutFrame *tmpFrame = [tmpLayouter layoutFrameWithRect:rect range:dirtyParagraphRange];
	
	NSArray *relayoutedLines = tmpFrame.lines;
	
	NSMutableArray *newLines = [[NSMutableArray alloc] init];
	
	NSMutableArray *suffixLines = [NSMutableArray array];
	
	NSUInteger indexInOldLines = 0;
	
	// copy the unchanged head
	for (DTCoreTextLayoutLine *oneLine in _lines)
	{
		NSUInteger startIndex = oneLine.stringRange.location;
		if (startIndex < dirtyParagraphRange.location)
		{
			[newLines addObject:oneLine];
			indexInOldLines++;
		}
		else if (startIndex>=NSMaxRange(dirtyParagraphRange))
		{
			[suffixLines addObject:oneLine];
		}
	}
	
	DTCoreTextLayoutLine *previousLine = [newLines lastObject];
	
	// copy the changed lines
	for (DTCoreTextLayoutLine *oneLine in relayoutedLines)
	{
		if (previousLine)
		{
            oneLine.baselineOrigin = [self baselineOriginToPositionLine:(id)oneLine afterLine:(id)previousLine options:DTCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit];
			[oneLine adjustStringRangeToStartAtIndex:NSMaxRange(previousLine.stringRange)];
		}
		
		[newLines addObject:oneLine];
		
		previousLine = oneLine;
	}
	
	// copy the rest
	for (DTCoreTextLayoutLine *oneLine in suffixLines)
	{
        oneLine.baselineOrigin = [self baselineOriginToPositionLine:(id)oneLine afterLine:(id)previousLine options:DTCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit];
		[oneLine adjustStringRangeToStartAtIndex:NSMaxRange(previousLine.stringRange)];
		
		[newLines addObject:oneLine];
		
		previousLine = oneLine;
	}
	
	// save
	_lines = newLines;
	
	previousLine = [_lines lastObject];
	
	// correct the overall frame size
	_frame.size.height = ceilf((CGRectGetMaxY(previousLine.frame) - _frame.origin.y + 1.5));
	
	// some attachments might have been overwritten, so we force refresh of the attachments list
	_textAttachments = nil;
}


- (CGRect)_frameCoveringLines:(NSArray *)array
{
	NSAssert([array count], @"cannot pass empty array");
	
	DTCoreTextLayoutLine *firstLine = [array objectAtIndex:0];
	CGRect rect = firstLine.frame;
	
	DTCoreTextLayoutLine *lastLine = [array lastObject];
	
	if (firstLine != lastLine)
	{
		rect = CGRectUnion(rect, lastLine.frame);
	}
	
	return CGRectIntegral(rect);
}


- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text dirtyRect:(CGRect *)dirtyRect
{
	dispatch_barrier_sync(_syncQueue, ^{
		
		NSString *plainText = [_attributedStringFragment string];
		
		// get beginning and end of paragraph containing the replaced range
		NSUInteger parBeginIndex;
		NSUInteger parEndIndex;
		NSRange rangeForRedoneParagraphs;
		
		// get the first and last index of the paragraphs containing this range
		rangeForRedoneParagraphs = [plainText rangeOfParagraphsContainingRange:range parBegIndex:&parBeginIndex parEndIndex:&parEndIndex];
		
		// if the range ends on a \n then we need to extend to include the following paragraph if it's actually a deletion
		if (parEndIndex < [plainText length] && ![text length])
		{
			if ([plainText indexIsAtBeginningOfParagraph:parEndIndex])
			{
				NSRange extendedRange = range;
				extendedRange.length += 1;
				rangeForRedoneParagraphs = [plainText rangeOfParagraphsContainingRange:extendedRange parBegIndex:&parBeginIndex parEndIndex:&parEndIndex];
			}
		}
		
		// text between begin of paragraph and insertion point is prefix
		NSAttributedString *prefix = nil;
		
		if (range.location > parBeginIndex)
		{
			NSRange prefixRange = NSMakeRange(parBeginIndex, range.location - parBeginIndex);
			prefix = [_attributedStringFragment attributedSubstringFromRange:prefixRange];
		}
		
		// text between end of paragraph and end of insertion range is suffix
		NSAttributedString *suffix = nil;
		
		NSInteger lastIndex = NSMaxRange(range);
		
		if (lastIndex < parEndIndex)
		{
			NSRange suffixRange = NSMakeRange(lastIndex, parEndIndex - lastIndex);
			suffix = [_attributedStringFragment attributedSubstringFromRange:suffixRange];
		}
		
		NSAttributedString *modifiedParagraphText;
		
		// we need to append a prefix or suffix
		if (prefix || suffix)
		{
			NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] init];
			
			if (prefix)
			{
				[tmpString appendAttributedString:prefix];
			}
			
			if (text)
			{
				[tmpString appendAttributedString:text];
			}
			
			if (suffix)
			{
				[tmpString appendAttributedString:suffix];
			}
			
			modifiedParagraphText = tmpString;
		}
		else
		{
			modifiedParagraphText = text;
		}
		
		
		// get affected paragraphs
		NSRange paragraphs = [self paragraphRangeContainingStringRange:rangeForRedoneParagraphs];
		
		if (![self.paragraphRanges count])
		{
			return;
		}
		
		// make this replacement in our local copy
		[(NSMutableAttributedString *)_attributedStringFragment replaceCharactersInRange:range withAttributedString:text];
		
		// layout the new paragraph text
		DTCoreTextLayouter *tmpLayouter = [[DTCoreTextLayouter alloc] initWithAttributedString:modifiedParagraphText];
		CGRect rect = self.frame;
		rect.size.height = CGFLOAT_HEIGHT_UNKNOWN;
		NSRange allTextRange = NSMakeRange(0, 0);
		DTCoreTextLayoutFrame *tmpFrame = [tmpLayouter layoutFrameWithRect:rect range:allTextRange];
		
		NSArray *relayoutedLines = tmpFrame.lines;
		
		NSUInteger insertionIndex = 0;
		
		if (paragraphs.location > 0)
		{
			NSArray *preParaLines = [self linesInParagraphAtIndex:paragraphs.location-1];
			
			DTCoreTextLayoutLine *lineBefore = [preParaLines lastObject];
			insertionIndex = [_lines indexOfObject:lineBefore] + 1;
		}
		
		
		// remove the changed lines
		NSMutableArray *tmpArray = [self.lines mutableCopy];
		NSMutableArray *replacedLines = [NSMutableArray array];
		
		for (NSInteger index=paragraphs.location; index < NSMaxRange(paragraphs); index++)
		{
			NSArray *lines = [self linesInParagraphAtIndex:index];
			[replacedLines addObjectsFromArray:lines];
			[tmpArray removeObjectsInArray:lines];
		}
		
		// this rect is the place where lines where removed, to be relayouted
		CGRect replacedLinesRect = [self _frameCoveringLines:replacedLines];
		
		// remove paragraph ranges
		_paragraphRanges = nil;
		
		DTCoreTextLayoutLine *previousLine = nil;
		
		// the amount that the relayouted lines need to be shifted down
		CGPoint insertedLinesBaselineOffset = CGPointZero;
		
		if (insertionIndex>0)
		{
			// if there is a line before this one we base ourselfs off that
			previousLine = [tmpArray objectAtIndex:insertionIndex-1];
			
			DTCoreTextLayoutLine *firstNewLine = [relayoutedLines objectAtIndex:0];
			
			CGPoint oldBaselineOrigin = firstNewLine.baselineOrigin;
			CGPoint newBaselineOrigin = [self baselineOriginToPositionLine:(id)firstNewLine afterLine:(id)previousLine options:DTCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit];
			
			insertedLinesBaselineOffset.y = newBaselineOrigin.y - oldBaselineOrigin.y;
		}
		
		// determine how much the range has to be shifted
		for (DTCoreTextLayoutLine *oneLine in tmpFrame.lines)
		{
			// only shift down if there are lines before it
			if (insertedLinesBaselineOffset.y!=0.0f)
			{
				CGPoint baselineOrigin = oneLine.baselineOrigin;
				baselineOrigin.y += insertedLinesBaselineOffset.y;
				oneLine.baselineOrigin = baselineOrigin;
			}
			
			[tmpArray insertObject:oneLine atIndex:insertionIndex];
			
			insertionIndex++;
			
			// adjust string range
			[oneLine adjustStringRangeToStartAtIndex:NSMaxRange(previousLine.stringRange)];
			
			previousLine = oneLine;
		}
		
		// this rect covers the freshly layouted replacement lines
		CGRect relayoutedLinesRect = [self _frameCoveringLines:tmpFrame.lines];
		
		BOOL firstLineAfterInsert = YES;
		CGPoint linesAfterinsertedLinesBaselineOffset = CGPointZero;
		
		// move down lines after the re-layouted lines
		while (insertionIndex<[tmpArray count])
		{
			DTCoreTextLayoutLine *oneLine = [tmpArray objectAtIndex:insertionIndex];
			
			// adjust string range
			[oneLine adjustStringRangeToStartAtIndex:NSMaxRange(previousLine.stringRange)];
			
			if (firstLineAfterInsert)
			{
				// first line determines shift down
				CGPoint oldBaselineOrigin = oneLine.baselineOrigin;
				CGPoint newBaselineOrigin = [self baselineOriginToPositionLine:(id)oneLine afterLine:(id)previousLine options:DTCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit];
				
				
				linesAfterinsertedLinesBaselineOffset.y = newBaselineOrigin.y - oldBaselineOrigin.y;
				
				// we got our offset now
				firstLineAfterInsert = NO;
			}
			
			CGPoint baselineOrigin =  oneLine.baselineOrigin;
			baselineOrigin.y += linesAfterinsertedLinesBaselineOffset.y;
			oneLine.baselineOrigin = baselineOrigin;
			
			previousLine = oneLine;
			insertionIndex++;
		}
		
		// save
		_lines = [tmpArray copy];
		
		// correct the overall frame size
		DTCoreTextLayoutLine *lastLine = [_lines lastObject];
		_frame.size.height = ceilf((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5));
		
		if (dirtyRect)
		{
			CGRect redrawArea = CGRectUnion(replacedLinesRect, relayoutedLinesRect);
			
			if (replacedLinesRect.origin.y != relayoutedLinesRect.origin.y || replacedLinesRect.size.height != relayoutedLinesRect.size.height)
			{
				// rest of document shifted up or down
				redrawArea.size.height = MAX(_frame.size.height - redrawArea.origin.y, redrawArea.size.height);
				redrawArea.size.width = _frame.size.width;
				redrawArea.origin.x = _frame.origin.x;
			}
			
			*dirtyRect = redrawArea;
		}
		
		// some attachments might have been overwritten, so we force refresh of the attachments list
		_textAttachments = nil;
		
		// next call needs new selection rectangles
		_cachedSelectionRectangles = nil;
	});
}

- (NSArray *)selectionRectsForRange:(NSRange)range
{
	if (_cachedSelectionRectangles && NSEqualRanges(range, _cachedSelectionRectanglesRange))
	{
		return _cachedSelectionRectangles;
	}
	
	_cachedSelectionRectangles = [super selectionRectsForRange:range];
	_cachedSelectionRectanglesRange = range;
	
	return _cachedSelectionRectangles;
}

- (void)drawInContext:(CGContextRef)context options:(DTCoreTextLayoutFrameDrawingOptions)options
{
	dispatch_sync(_syncQueue, ^{
		
		[super drawInContext:context options:options];
	});
}

#pragma mark - Properties

- (void)setFrame:(CGRect)frame
{
	if (CGPointEqualToPoint(_frame.origin, frame.origin) && _frame.size.width == frame.size.width)
	{
		return;
	}
	
	_frame = frame;
	
	// next call needs new selection rectangles
	_cachedSelectionRectangles = nil;
	
	if (shouldRebuildLines)
	{
		[self relayoutText];
	}
}

@end
