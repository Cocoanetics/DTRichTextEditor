//
//  DTCoreTextLayoutFrame+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCoreTextLayoutFrame+DTRichText.h"

#import "DTTextPosition.h"
#import "DTTextRange.h"
#import "DTCoreTextLayoutLine.h"

@implementation DTCoreTextLayoutFrame (DTRichText)

// a rectangle starting encompassing the range, or first line whichever is smaller
- (CGRect)firstRectForRange:(NSRange)range
{
	NSInteger firstIndex = range.location;
	NSInteger firstIndexLine = [self lineIndexForGlyphIndex:firstIndex];
	
	NSInteger lastIndex = range.location + range.length;
	NSInteger lastIndexLine = [self lineIndexForGlyphIndex:lastIndex];
	
	CGRect firstIndexRect = [self frameOfGlyphAtIndex:firstIndex];
	CGRect lastIndexRect;
	
	if (lastIndexLine==firstIndexLine)
	{
		lastIndexRect = [self frameOfGlyphAtIndex:lastIndex];
		
		return CGRectMake(firstIndexRect.origin.x, firstIndexRect.origin.y, lastIndexRect.origin.x - firstIndexRect.origin.x, firstIndexRect.size.height);
	}
	
	// get until end of line
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:firstIndexLine];
	
	return CGRectMake(roundf(firstIndexRect.origin.x), roundf(firstIndexRect.origin.y), roundf(line.frame.origin.x + line.frame.size.width - firstIndexRect.origin.x), roundf(firstIndexRect.size.height));
}

- (NSArray *)selectionRectsForRange:(NSRange)range
{
	NSInteger firstIndex = range.location;
	NSInteger firstIndexLine = [self lineIndexForGlyphIndex:firstIndex];
	
	NSInteger lastIndex = range.location + range.length;
	NSInteger lastIndexLine = [self lineIndexForGlyphIndex:lastIndex];
	
	
	NSMutableArray *tmpArray = [NSMutableArray array];

	
	NSInteger numberOfLines = [self.lines count];
	if (firstIndexLine>=numberOfLines || lastIndexLine>=numberOfLines)
	{
		NSLog(@"Problem!");
		
		lastIndexLine = MIN(numberOfLines-1, lastIndexLine);
	}
	
	for (NSInteger i = firstIndexLine; i<=lastIndexLine; i++)
	{
		DTCoreTextLayoutLine *line = [self.lines objectAtIndex:i];
		
		NSRange range = [line stringRange];
		NSInteger lastInRange = range.location + range.length;
		
		NSInteger firstIndexInLine = MIN(MAX(range.location, firstIndex), lastInRange);

		CGRect firstIndexRect = [self frameOfGlyphAtIndex:firstIndexInLine];
		
		CGRect rect;
		
		if (lastIndex < lastInRange)
		{
			// in same line
			CGRect lastIndexRect = [self frameOfGlyphAtIndex:lastIndex];
			rect =  CGRectMake(firstIndexRect.origin.x, firstIndexRect.origin.y, lastIndexRect.origin.x - firstIndexRect.origin.x, firstIndexRect.size.height);
		}
		else 
		{
			// ending after this line
			rect = CGRectMake(firstIndexRect.origin.x, firstIndexRect.origin.y, line.frame.origin.x + line.frame.size.width - firstIndexRect.origin.x, firstIndexRect.size.height);
		}

		[tmpArray addObject:[NSValue valueWithCGRect:rect]];

	}
	
	return [NSArray arrayWithArray:tmpArray];
}

- (NSInteger)indexForPositionUpwardsFromIndex:(NSInteger)index offset:(NSInteger)offset
{
	NSInteger lineIndex = [self lineIndexForGlyphIndex:index];
	NSInteger newLineIndex = lineIndex - offset;

	
	if (newLineIndex<0)
	{
		return -1;
	}
	
	CGRect currentRect = [self frameOfGlyphAtIndex:index];
	
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:newLineIndex];
	NSRange range = [line stringRange];
	
	NSInteger closestIndex = -1;
	CGFloat closestDistance = CGFLOAT_MAX;

	
	for (int i=0; i<range.length; i++)
	{
		NSInteger testIndex = i + range.location;
		
		CGRect rect = [self frameOfGlyphAtIndex:testIndex];
		
		CGFloat horizDistance = fabs(rect.origin.x - currentRect.origin.x);
		
		if (horizDistance < closestDistance)
		{
			closestDistance = horizDistance;
			closestIndex = testIndex;
		}
	}
	
	if (closestIndex>=0)
	{
		return closestIndex;
	}
	
	
	return -1;
}

- (NSInteger)indexForPositionDownwardsFromIndex:(NSInteger)index offset:(NSInteger)offset
{
	NSInteger lineIndex = [self lineIndexForGlyphIndex:index];
	NSInteger newLineIndex = lineIndex + offset;
	
	if (newLineIndex >= [self.lines count])
	{
		return -1;
	}
	
	CGRect currentRect = [self frameOfGlyphAtIndex:index];
	
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:newLineIndex];
	NSRange range = [line stringRange];
	
	NSInteger closestIndex = -1;
	CGFloat closestDistance = CGFLOAT_MAX;
	
	
	for (int i=0; i<range.length; i++)
	{
		NSInteger testIndex = i + range.location;
		
		CGRect rect = [self frameOfGlyphAtIndex:testIndex];
		
		CGFloat horizDistance = fabs(rect.origin.x - currentRect.origin.x);
		
		if (horizDistance < closestDistance)
		{
			closestDistance = horizDistance;
			closestIndex = testIndex;
		}
	}
	
	if (closestIndex>0)
	{
		return closestIndex;
	}
	
	
	return -1;
}



- (NSInteger)closestIndexToPoint:(CGPoint)point
{
	NSRange range = [self visibleStringRange];

	NSInteger closestIndex = -1;
	CGFloat closestDistance = CGFLOAT_MAX;
	
	for (int i=0; i<range.length; i++)
	{
		NSInteger testIndex = i + range.location;
		
		CGRect rect = [self frameOfGlyphAtIndex:testIndex];
		rect.size.width = 3.0;
		
		CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
		
		
		CGFloat dx = center.x - point.x;
		CGFloat dy = center.y - point.y;

		CGFloat distance = sqrtf(dx*dx + dy*dy);
		
		if (distance < closestDistance)
		{
			closestDistance = distance;
			closestIndex = testIndex;
		}
	}
	
	if (closestIndex>=0)
	{
		return closestIndex;
	}
	
	return -1;
}


- (NSInteger)closestCursorIndexToPoint:(CGPoint)point
{
	NSArray *lines = self.lines;
	
	if (![lines count])
	{
		return -1;
	}
	
	DTCoreTextLayoutLine *firstLine = [lines objectAtIndex:0];
	if (point.y < CGRectGetMinY(firstLine.frame))
	{
		return 0;
	}
	
	DTCoreTextLayoutLine *lastLine = [lines lastObject];
	if (point.y > CGRectGetMaxY(lastLine.frame))
	{
		return NSMaxRange([self visibleStringRange])-1;
	}
	
	// find closest line
	DTCoreTextLayoutLine *closestLine = nil;
	CGFloat closestDistance = CGFLOAT_MAX;
	
	for (DTCoreTextLayoutLine *oneLine in lines)
	{
		// line contains point 
		if (CGRectGetMinY(oneLine.frame) <= point.y && CGRectGetMaxY(oneLine.frame) >= point.y)
		{
			closestLine = oneLine;
			break;
		}
		
		CGFloat top = CGRectGetMinY(oneLine.frame);
		CGFloat bottom = CGRectGetMaxY(oneLine.frame);
		
		CGFloat distance = CGFLOAT_MAX;
		
		if (top > point.y)
		{
			distance = top - point.y;
		}
		else if (bottom < point.y)
		{
			distance = point.y - bottom;
		}
		
		if (distance < closestDistance)
		{
			closestLine = oneLine;
			closestDistance = distance;
		}
	}
	
	if (!closestLine)
	{
		return -1;
	}
	
	// find the closest index in this line
	NSInteger closestIndex = -1;
	NSRange range = [closestLine stringRange];
	
	closestDistance = CGFLOAT_MAX;
	
	for (int i=0; i<range.length; i++)
	{
		NSInteger testIndex = i + range.location;
		
		CGRect rect = [closestLine frameOfGlyphAtIndex:i];
		rect.size.width = 3.0;
		CGFloat mid = CGRectGetMidX(rect);
		
		CGFloat horizDistance = fabs(point.x - mid);
		
		if (horizDistance < closestDistance)
		{
			closestDistance = horizDistance;
			closestIndex = testIndex;
		}
	}
	
	if (closestIndex>=0)
	{
		return closestIndex;
	}
	
	return -1;
}

@end
