//
//  DTRichTextEditorView+Ranges.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView+Ranges.h"

#import <DTCoreText/DTAttributedTextContentView.h>
#import <DTCoreText/NSString+Paragraphs.h>

@implementation DTRichTextEditorView (Ranges)

#pragma mark - Working with Ranges
- (UITextRange *)textRangeOfWordAtPosition:(UITextPosition *)position
{
	DTTextRange *forRange = (id)[[self tokenizer] rangeEnclosingPosition:position withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
	DTTextRange *backRange = (id)[[self tokenizer] rangeEnclosingPosition:position withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
	
	if (forRange && backRange)
	{
		DTTextRange *newRange = [DTTextRange textRangeFromStart:[backRange start] toEnd:[backRange end]];
		return newRange;
	}
	else if (forRange)
	{
		return forRange;
	}
	else if (backRange)
	{
		return backRange;
	}
	
	// treat image as word, left side of image selects it
	UITextPosition *plusOnePosition = [self positionFromPosition:position offset:1];
	UITextRange *imageRange = [self textRangeFromPosition:position toPosition:plusOnePosition];
	
	NSAttributedString *characterString = [self attributedSubstringForRange:imageRange];
	
    // only check for attachment attribute if the string is not empty
    if ([characterString length])
    {
        if ([[characterString attributesAtIndex:0 effectiveRange:NULL] objectForKey:NSAttachmentAttributeName])
        {
            return imageRange;
        }
    }
	
	// we did not get a forward or backward range, like Word!|
	DTTextPosition *previousPosition = (id)([self.tokenizer positionFromPosition:position
                                                                      toBoundary:UITextGranularityCharacter
                                                                     inDirection:UITextStorageDirectionBackward]);
	
	// treat image as word, right side of image selects it
	characterString = [self.attributedTextContentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:NSMakeRange(previousPosition.location, 1)];
	
	if ([[characterString attributesAtIndex:0 effectiveRange:NULL] objectForKey:NSAttachmentAttributeName])
	{
		return [DTTextRange textRangeFromStart:previousPosition toEnd:[previousPosition textPositionWithOffset:1]];
	}
	
	forRange = (id)[[self tokenizer] rangeEnclosingPosition:previousPosition withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
	backRange = (id)[[self tokenizer] rangeEnclosingPosition:previousPosition withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
	
	UITextRange *retRange = nil;
	
	if (forRange && backRange)
	{
		retRange = [DTTextRange textRangeFromStart:[backRange start] toEnd:[backRange end]];
	}
	else if (forRange)
	{
		retRange = forRange;
	}
	else if (backRange)
	{
		retRange = backRange;
	}
	
	// need to extend to include the previous position
	if (retRange)
	{
		// extend this range to go up to current position
		return [DTTextRange textRangeFromStart:[retRange start] toEnd:position];
	}
	
	return nil;
}

- (UITextRange *)textRangeOfURLAtPosition:(UITextPosition *)position URL:(NSURL **)URL
{
	NSUInteger index = [(DTTextPosition *)position location];
	
	NSRange effectiveRange;
	
	NSURL *effectiveURL = [self.attributedTextContentView.layoutFrame.attributedStringFragment attribute:DTLinkAttribute atIndex:index effectiveRange:&effectiveRange];
	
	if (!effectiveURL)
	{
		return nil;
	}
	
	DTTextRange *range = [DTTextRange rangeWithNSRange:effectiveRange];
	
	if (URL)
	{
		*URL = effectiveURL;
	}
	
	return range;
}

// returns the text range containing a given string index
- (UITextRange *)textRangeOfParagraphContainingPosition:(UITextPosition *)position
{
	NSAttributedString *attributedString = self.attributedText;
	NSString *string = [attributedString string];
	
    NSRange range = [string rangeOfParagraphAtIndex:[(DTTextPosition *)position location]];
    
	DTTextRange *retRange = [DTTextRange rangeWithNSRange:range];
    
	return retRange;
}

- (UITextRange *)textRangeOfParagraphsContainingRange:(UITextRange *)range
{
	NSRange myRange = [(DTTextRange *)range NSRangeValue];
    myRange.length ++;
	
	// get range containing all selected paragraphs
	NSAttributedString *attributedString = self.attributedText;
	
	NSString *string = [attributedString string];
	
	NSUInteger begIndex;
	NSUInteger endIndex;
	
	[string rangeOfParagraphsContainingRange:myRange parBegIndex:&begIndex parEndIndex:&endIndex];
	myRange = NSMakeRange(begIndex, endIndex - begIndex); // now extended to full paragraphs
	
	DTTextRange *retRange = [DTTextRange rangeWithNSRange:myRange];
    
	return retRange;
}

@end
