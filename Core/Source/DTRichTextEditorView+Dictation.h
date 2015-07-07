//
//  DTRichTextEditorView+Dictation.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTDictationPlaceholderTextAttachment;

#import "DTRichTextEditorView.h"

/**
 The **Dictation** category contains methods to support dictation input.
 */

@interface DTRichTextEditorView (Dictation)

/**
 Retrieves the range of the first dictation placeholder in the text.
 
 You can use this to replace the dictation placeholder with the recognized text.
 @returns The selection range
 */
- (UITextRange *)textRangeOfDictationPlaceholder;


/**
 Convenience method to retrieve the placeholder object at the given position.
 
 @param position The text position to retrieve the placeholder from
 @returns The dictation placeholder or `nil` if there is none at the given text position.
 */
- (DTDictationPlaceholderTextAttachment *)dictationPlaceholderAtPosition:(UITextPosition *)position;

@end
