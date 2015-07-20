//
//  DTRichTextEditorView+Dictation.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"
#import <DTCoreText/DTCoreText.h>

@interface DTRichTextEditorView (private)

@property (nonatomic, retain) DTTextSelectionView *selectionView;
@property (nonatomic, assign) BOOL waitingForDictionationResult;
@property (nonatomic, retain) DTDictationPlaceholderView *dictationPlaceholderView;

- (void)_inputDelegateTextWillChange;
- (void)_inputDelegateTextDidChange;

@end

@implementation DTRichTextEditorView (Dictation)


- (void)insertDictationResult:(NSArray *)dictationResult
{
	NSMutableString *tmpString = [NSMutableString string];
	
	for (UIDictationPhrase *phrase in dictationResult)
	{
		[tmpString appendString:phrase.text];
	}

	unichar lastChar = [tmpString characterAtIndex:[tmpString length]-1];
	
	if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:lastChar])
	{
		[tmpString appendString:@" "];
	}

	[self insertText:tmpString];
	[self.undoManager setActionName:NSLocalizedString(@"Dictation", @"Undo Action when text is entered via dictation")];
}

- (void)dictationRecordingDidEnd
{
	[self.undoManager endUndoGrouping];
	
	// make a placeholder attachment, will be creating a placeholderView at run time
	DTDictationPlaceholderTextAttachment *attachment = [[DTDictationPlaceholderTextAttachment alloc] init];
    
    UITextRange *range = (DTTextRange *)[self selectedTextRange];
    // remember the replaced text in the attachment
    attachment.replacedAttributedString = [self attributedSubstringForRange:range];

    // we don't want the inserting of the image to be an undo step
    [self.undoManager disableUndoRegistration];

	// no need for an extra space, dictation does that for us
	
    // replace the selected text with the placeholder
	[self replaceRange:range withAttachment:attachment inParagraph:NO];
	
    [self.undoManager enableUndoRegistration];
    
    // this hides the selection until replaceRange:withText: inserts the result
    self.waitingForDictionationResult = YES;
}

-(void)dictationRecognitionFailed{
    //removeDictationResultPlaceholder is not invoked if no text was inserted, calling it manually
    [self removeDictationResultPlaceholder:nil willInsertResult:NO];
    //workaround for the mic to be enabled again
    [self.inputDelegate selectionWillChange:self];
    [self.inputDelegate selectionDidChange:self];
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

    NSLog(@"No dictation placeholder at index %lu", (unsigned long)index);
    return nil;
}

@end
