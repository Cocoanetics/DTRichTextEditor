//
//  DTRichTextEditorView+Dictation.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

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

@end
