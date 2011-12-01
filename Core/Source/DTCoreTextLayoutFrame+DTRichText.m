//
//  DTCoreTextLayoutFrame+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/25/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
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
	DTCoreTextLayoutLine *firstIndexLine = [self lineContainingIndex:firstIndex];
	
	NSInteger lastIndex = range.location + range.length;
	DTCoreTextLayoutLine *lastIndexLine = [self lineContainingIndex:lastIndex];
	
	CGRect firstIndexRect = [self cursorRectAtIndex:firstIndex];
	CGRect lastIndexRect;
	
	if (lastIndexLine==firstIndexLine)
	{
		lastIndexRect = [self cursorRectAtIndex:lastIndex];
		
		return CGRectMake(firstIndexRect.origin.x, firstIndexLine.frame.origin.y, lastIndexRect.origin.x - firstIndexRect.origin.x, firstIndexLine.frame.size.height);
	}
	
	// get until end of line
	return CGRectMake(roundf(firstIndexRect.origin.x), roundf(firstIndexLine.frame.origin.y), roundf(firstIndexLine.frame.origin.x + firstIndexLine.frame.size.width - firstIndexRect.origin.x), roundf(firstIndexLine.frame.size.height));
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
		lastIndexLine = MIN(numberOfLines-1, lastIndexLine);
	}
	
	for (NSInteger i = firstIndexLine; i<=lastIndexLine; i++)
	{
		DTCoreTextLayoutLine *line = [self.lines objectAtIndex:i];
		
		NSRange range = [line stringRange];
		NSInteger lastInRange = range.location + range.length;
		
		NSInteger firstIndexInLine = MIN(MAX(range.location, firstIndex), lastInRange);
        
		CGRect firstIndexRect = [self cursorRectAtIndex:firstIndexInLine];
		
		CGRect rect;
		
        if (lastIndex > range.location)
        {
            if (lastIndex < lastInRange)
            {
                // in same line
                CGRect lastIndexRect = [self cursorRectAtIndex:lastIndex];
                rect =  CGRectMake(firstIndexRect.origin.x, line.frame.origin.y, lastIndexRect.origin.x - firstIndexRect.origin.x, line.frame.size.height);
            }
            else 
            {
                // ending after this line
                rect = CGRectMake(firstIndexRect.origin.x, line.frame.origin.y, line.frame.origin.x + self.frame.size.width - firstIndexRect.origin.x, line.frame.size.height);
            }
            
            [tmpArray addObject:[NSValue valueWithCGRect:rect]];
        }
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
	
	CGRect currentRect = [self cursorRectAtIndex:index];
	
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:newLineIndex];
	NSInteger closestIndex = [line stringIndexForPosition:CGPointMake(currentRect.origin.x, line.frame.origin.y)];
	
	return closestIndex;
}

- (NSInteger)indexForPositionDownwardsFromIndex:(NSInteger)index offset:(NSInteger)offset
{
	NSInteger lineIndex = [self lineIndexForGlyphIndex:index];
	NSInteger newLineIndex = lineIndex + offset;
	
	if (newLineIndex >= [self.lines count])
	{
		return -1;
	}
	
	CGRect currentRect = [self cursorRectAtIndex:index];
	
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:newLineIndex];
	NSInteger closestIndex = [line stringIndexForPosition:CGPointMake(currentRect.origin.x, line.frame.origin.y)];
	
	return closestIndex;
}



- (NSInteger)closestIndexToPoint:(CGPoint)point
{
	NSRange range = [self visibleStringRange];
    
	NSInteger closestIndex = -1;
	CGFloat closestDistance = CGFLOAT_MAX;
	
	for (int i=0; i<range.length; i++)
	{
		NSInteger testIndex = i + range.location;
		
		CGRect rect = [self cursorRectAtIndex:testIndex];
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
		return kCFNotFound;
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
		return kCFNotFound;
	}
	
	NSInteger closestIndex = [closestLine stringIndexForPosition:point];
	
	NSInteger maxIndex = NSMaxRange([closestLine stringRange])-1;
	
	if (closestIndex > maxIndex)
	{
		closestIndex = maxIndex;
	}
	
	if (closestIndex>=0)
	{
		return closestIndex;
	}
	
	return kCFNotFound;
}

- (CGRect)cursorRectAtIndex:(NSInteger)index
{
	DTCoreTextLayoutLine *line = [self lineContainingIndex:index];
	
	if (!line)
	{
		return CGRectZero;
	}
	
	CGFloat offset = [line offsetForStringIndex:index];
	
	CGRect rect = line.frame;
	rect.size.width = 3.0;
	rect.origin.x += offset;
	
	return rect;
}

@end
