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


// insertDictationResult: is invoked when there is more than one possible interpretation of the dictated phrase.
// Rather than simply inserting every possibility, the UI could somehow indicate that multiple results exist.
// (A standard UITextView will underline an ambiguous result and provide alternatives when tapped.)
// If this method is not implemented, the default behavior is to choose the most likely interpretation.

//- (void)insertDictationResult:(NSArray *)dictationResult
//{
//	NSMutableString *tmpString = [NSMutableString string];
//	
//	for (UIDictationPhrase *phrase in dictationResult)
//	{
//		[tmpString appendString:phrase.text];
//	}
//
//	unichar lastChar = [tmpString characterAtIndex:[tmpString length]-1];
//	
//	if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:lastChar])
//	{
//		[tmpString appendString:@" "];
//	}
//
//	[self insertText:tmpString];
//	[self.undoManager setActionName:NSLocalizedString(@"Dictation", @"Undo Action when text is entered via dictation")];
//}


// insertDictationResultPlaceholder is invoked after "Done" is tapped.
// Preliminary results may already have been inserted into the text by the time this method is called.
- (id)insertDictationResultPlaceholder
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
    
    return attachment;
}

// removeDictationResultPlaceholder:willInsertResult: is invoked after the dictation has been processed.
// Despite the "willInsert" nomenclature, the dictation result has already been inserted into the text by the time this method is called.
- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult
{
    // placeholder is the object returned by insertDictationResultPlaceholder.
    
    UITextRange *range = [self textRangeOfDictationPlaceholder];
    
    if (range)
    {
        // we don't want the removal of the placeholder to be an undo step
        [self.undoManager disableUndoRegistration];
        
        [self replaceRange:range withText:@""];
        
        [self.undoManager enableUndoRegistration];
    }
}

-(void)dictationRecognitionFailed
{
    //removeDictationResultPlaceholder is not invoked if no text was inserted, calling it manually
    [self removeDictationResultPlaceholder:[NSNull null] willInsertResult:NO];
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
