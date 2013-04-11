//
//  DTRichTextEditorView+Lists.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView.h"

@interface DTRichTextEditorView (Lists)

/**
 Toggles a list style on a given range.
 @param listStyle the list style to toggle
 @param range The text range
 */
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range;

@end
