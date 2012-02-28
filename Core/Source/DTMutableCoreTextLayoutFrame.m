	//
//  DTMutableCoreTextLayoutFrame.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/23/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTMutableCoreTextLayoutFrame.h"

#import "DTCoreTextLayoutLine.h"
#import "NSString+Paragraphs.h"
#import "DTCoreTextLayouter.h"

#import "DTRichTextCategories.h"



@implementation DTMutableCoreTextLayoutFrame

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
		
		// we don't need a layouter because we create a temporary one if we need it
	}
	
	return self;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (attributedString != _attributedStringFragment)
	{
		[_attributedStringFragment release];
		_attributedStringFragment = [attributedString mutableCopy];
		
		[self relayoutText];
	}
}

- (void)relayoutText
{
	// layout the new text
	DTCoreTextLayouter *tmpLayouter = [[DTCoreTextLayouter alloc] initWithAttributedString:_attributedStringFragment];
	CGRect rect = _frame;
	rect.size.height = CGFLOAT_OPEN_HEIGHT;
	NSRange allTextRange = NSMakeRange(0, 0);
	DTCoreTextLayoutFrame *tmpFrame = [tmpLayouter layoutFrameWithRect:rect range:allTextRange];
	
	// transfer the lines
	[_lines autorelease];
	_lines = [tmpFrame.lines copy];
	
	[tmpLayouter release];
	
	// correct the overall frame size
	DTCoreTextLayoutLine *lastLine = [_lines lastObject];
	_frame.size.height = ceilf((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5));
	
	// some attachments might have been overwritten, so we force refresh of the attachments list
	[_textAttachments release], _textAttachments = nil;
}


- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text
{
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
        NSMutableAttributedString *tmpString = [[[NSMutableAttributedString alloc] init] autorelease];
        
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
    rect.size.height = CGFLOAT_OPEN_HEIGHT;
    NSRange allTextRange = NSMakeRange(0, 0);
    DTCoreTextLayoutFrame *tmpFrame = [tmpLayouter layoutFrameWithRect:rect range:allTextRange];
	
	NSArray *relayoutedLines = tmpFrame.lines;
	
	[tmpLayouter release];
    
    NSUInteger insertionIndex = 0;
	
	if (paragraphs.location > 0)
	{
		NSArray *preParaLines = [self linesInParagraphAtIndex:paragraphs.location-1];
		
		DTCoreTextLayoutLine *lineBefore = [preParaLines lastObject];
		insertionIndex = [_lines indexOfObject:lineBefore] + 1; 
	}
	
	
	// remove the changed lines
    NSMutableArray *tmpArray = [[self.lines mutableCopy] autorelease];
    
    for (NSInteger index=paragraphs.location; index < NSMaxRange(paragraphs); index++)
    {
		
        NSArray *lines = [self linesInParagraphAtIndex:index];
        [tmpArray removeObjectsInArray:lines];
    }
	
	// remove paragraph ranges
	[_paragraphRanges release], _paragraphRanges = nil;
	

	DTCoreTextLayoutLine *previousLine = nil;
	
	// the amount that the relayouted lines need to be shifted down
	CGPoint insertedLinesBaselineOffset = CGPointZero;
	
	if (insertionIndex>0)
	{
		// if there is a line before this one we base ourselfs off that
		previousLine = [tmpArray objectAtIndex:insertionIndex-1];
		
		DTCoreTextLayoutLine *firstNewLine = [relayoutedLines objectAtIndex:0];

		CGPoint oldBaselineOrigin = firstNewLine.baselineOrigin;
		CGPoint newBaselineOrigin = [firstNewLine baselineOriginToPositionAfterLine:previousLine];
		
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
		
		previousLine = oneLine;
    }
    
	BOOL firstLineAfterInsert = YES;
	CGPoint linesAfterinsertedLinesBaselineOffset = CGPointZero;

	// move down lines after the re-layouted lines
	while (insertionIndex<[tmpArray count]) 
	{
		DTCoreTextLayoutLine *oneLine = [tmpArray objectAtIndex:insertionIndex];
		
		if (firstLineAfterInsert)
		{
			// first line determines shift down
			CGPoint oldBaselineOrigin = oneLine.baselineOrigin;
			CGPoint newBaselineOrigin = [oneLine baselineOriginToPositionAfterLine:previousLine];
			
			linesAfterinsertedLinesBaselineOffset.y = newBaselineOrigin.y - oldBaselineOrigin.y;
			
			// we got our offset now
			firstLineAfterInsert = NO;
		}
		
		CGPoint baselineOrigin =  [oneLine baselineOriginToPositionAfterLine:previousLine];
		baselineOrigin.y += linesAfterinsertedLinesBaselineOffset.y;
		oneLine.baselineOrigin = baselineOrigin;
		
		previousLine = oneLine;
		insertionIndex++;
	}
	
	// make sure that all string ranges are continuous
	NSInteger nextIndex = 0;
	
	for (DTCoreTextLayoutLine *oneLine in tmpArray)
	{
		[oneLine adjustStringRangeToStartAtIndex:nextIndex];
		
		nextIndex = NSMaxRange([oneLine stringRange]);
	}
	
    // save 
	[_lines autorelease];
    _lines = [tmpArray copy];
	
	// correct the overall frame size
	DTCoreTextLayoutLine *lastLine = [_lines lastObject];
	_frame.size.height = ceilf((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5));
	
	// some attachments might have been overwritten, so we force refresh of the attachments list
	[_textAttachments release], _textAttachments = nil;
}

- (void)setFrame:(CGRect)frame
{
	_frame = frame;
    
    if (shouldRebuildLines) {
        [self relayoutText];
    }
}


@end
