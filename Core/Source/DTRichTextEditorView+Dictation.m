//
//  DTRichTextEditorView+Dictation.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"
#import "DTDictationPlaceholderView.h"

@interface DTRichTextEditorView (private)

@property (nonatomic, retain) DTTextSelectionView *selectionView;
@property (nonatomic, assign) BOOL waitingForDictionationResult;
@property (nonatomic, retain) DTDictationPlaceholderView *dictationPlaceholderView;

@end

@implementation DTRichTextEditorView (Dictation)

- (void)dictationRecordingDidEnd
{
	// make a placeholder attachment, will be creating a placeholderView at run time
	DTDictationPlaceholderTextAttachment *attachment = [[DTDictationPlaceholderTextAttachment alloc] init];
    
    UITextRange *range = (DTTextRange *)[self selectedTextRange];
    // remember the replaced text in the attachment
    attachment.replacedAttributedString = [self attributedSubstringForRange:range];

    // we don't want the inserting of the image to be an undo step
    [self.undoManager disableUndoRegistration];

    // add an extra space if text before the dictation insertion does not end with whitespace
    if ([self comparePosition:[self beginningOfDocument] toPosition:[range start]] == NSOrderedAscending)
    {
        // not at beginning of document, check that there is a space
        UITextPosition *positionBefore = [self positionFromPosition:[range start] offset:-1];
        
        UITextRange *spaceRange = [self textRangeFromPosition:positionBefore toPosition:[range start]];
        NSString *characterBefore = [[self attributedSubstringForRange:spaceRange] string];
        
        // is not whitespace
        if ([[characterBefore stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0)
        {
            [self replaceRange:range withText:@" "];
            
            // advance insertion position
            UITextPosition *positionAfter = [self positionFromPosition:[range start] offset:1];
            range = [self textRangeFromPosition:positionAfter toPosition:positionAfter];
        }
    }
    
    // replace the selected text with the placeholder
	[self replaceRange:range withAttachment:attachment inParagraph:NO];

    [self.undoManager enableUndoRegistration];
    
    // this hides the selection until replaceRange:withText: inserts the result
    self.waitingForDictionationResult = YES;
}

- (UITextRange *)textRangeOfDictationPlaceholder
{
    __block NSRange foundRange = NSMakeRange(0, 0);
    
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, [self.attributedText length]) options:0 usingBlock:^(DTTextAttachment *value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[DTDictationPlaceholderTextAttachment class]])
        {
            foundRange = range;
            *stop = YES;
        }
    }];
    
    if (!foundRange.length)
    {
        return nil;
    }
    
    
    return [DTTextRange rangeWithNSRange:foundRange];
}

- (DTDictationPlaceholderTextAttachment *)dictationPlaceholderAtPosition:(UITextPosition *)position
{
    DTTextPosition *myPosition = (DTTextPosition *)position;
    NSUInteger index = myPosition.location;
    
    NSRange range;
    DTDictationPlaceholderTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
    
    if (range.length!=1)
    {
        NSLog(@"Dictation Placholder range length should only be 1");
        return nil;
    }

    if ([attachment isKindOfClass:[DTDictationPlaceholderTextAttachment class]])
    {
        return attachment;
    }

    NSLog(@"No dictation placeholder at index %d", index);
    return nil;
}

@end
