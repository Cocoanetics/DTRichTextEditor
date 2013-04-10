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
#import "DTTextSelectionRect.h"

@implementation DTCoreTextLayoutFrame (DTRichText)

- (CGRect)firstRectForRange:(NSRange)range
{
    NSArray *tmpRects = [self selectionRectsForRange:range];
    
    if (![tmpRects count])
    {
        return CGRectZero;
    }
    
    DTTextSelectionRect *firstRect = [tmpRects objectAtIndex:0];
    
    return firstRect.rect;
}

- (NSArray *)selectionRectsForRange:(NSRange)range
{
    NSInteger fromIndex = range.location;
    NSInteger toIndex = range.location + range.length;
    
    CGFloat fromCaretOffset;
    CGFloat toCaretOffset;
    
    BOOL haveStart = NO;
    BOOL haveEnd = NO;
    
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
    
    for (DTCoreTextLayoutLine *oneLine in self.lines)
	{
        BOOL lineContainsStart = NO;
        BOOL lineContainsEnd = NO;
        
		if (NSLocationInRange(fromIndex, [oneLine stringRange]))
		{
            lineContainsStart = YES;
            haveStart = YES;
            
           fromCaretOffset = [oneLine offsetForStringIndex:fromIndex] + oneLine.frame.origin.x;
        }

        if (NSLocationInRange(toIndex, [oneLine stringRange]))
		{
            lineContainsEnd = YES;;
            haveEnd = YES;
            
            toCaretOffset = [oneLine offsetForStringIndex:toIndex] + oneLine.frame.origin.x;
        }
        
        CGRect rectToAddForThisLine = oneLine.frame;
        
        // continue looping through lines until we find the start
        if (!haveStart)
        {
            continue;
        }

        if (lineContainsStart)
        {
            if (lineContainsEnd)
            {
                rectToAddForThisLine = CGRectStandardize(CGRectMake(fromCaretOffset, oneLine.frame.origin.y, toCaretOffset - fromCaretOffset, oneLine.frame.size.height));
            }
            else
            {
                // ending after this line
                
                if (oneLine.writingDirectionIsRightToLeft)
                {
                    // extend to left side of line
                    rectToAddForThisLine = CGRectMake(oneLine.frame.origin.x, oneLine.frame.origin.y, fromCaretOffset - oneLine.frame.origin.x, oneLine.frame.size.height);
                }
                else
                {
                    // extend to right side of line
                    rectToAddForThisLine = CGRectMake(fromCaretOffset, oneLine.frame.origin.y, oneLine.frame.origin.x + self.frame.size.width - fromCaretOffset, oneLine.frame.size.height);
                }
            }
        }
        else
        {
            if (lineContainsEnd)
            {
                if (oneLine.writingDirectionIsRightToLeft)
                {
                    // extend to right side of line
                    rectToAddForThisLine = CGRectMake(toCaretOffset, oneLine.frame.origin.y, oneLine.frame.origin.x + self.frame.size.width - toCaretOffset, oneLine.frame.size.height);
                }
                else
                {
                    // extend to left side of line
                    rectToAddForThisLine = CGRectMake(oneLine.frame.origin.x, oneLine.frame.origin.y, toCaretOffset - oneLine.frame.origin.x, oneLine.frame.size.height);
                }
            }
        }
        
        // make new DTTextSelectionRect, was NSValue with CGRect before
        DTTextSelectionRect *selectionRect = [DTTextSelectionRect textSelectionRectWithRect:CGRectIntegral(rectToAddForThisLine)];
        
        selectionRect.containsStart = lineContainsStart;
        selectionRect.containsEnd = lineContainsEnd;
        
        [retArray addObject:selectionRect];
        
        if (haveStart && haveEnd)
        {
            // we're done
            break;
        }
    }
    
    if ([retArray count])
    {
        return retArray;
    }
    
    return nil;
}

- (NSInteger)indexForPositionUpwardsFromIndex:(NSInteger)index offset:(NSInteger)offset
{
	NSInteger lineIndex = [self lineIndexForGlyphIndex:index];
	NSInteger newLineIndex = lineIndex - offset;
    
	
	if (newLineIndex<0)
	{
		return NSNotFound;
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
		return NSNotFound;
	}
	
	CGRect currentRect = [self cursorRectAtIndex:index];
	
	DTCoreTextLayoutLine *line = [self.lines objectAtIndex:newLineIndex];
	NSInteger closestIndex = [line stringIndexForPosition:CGPointMake(currentRect.origin.x, line.frame.origin.y)];
	
	return closestIndex;
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
        NSRange stringRange = [self visibleStringRange];
        
        if (stringRange.length)
        {
            return NSMaxRange([self visibleStringRange])-1;
        }
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
