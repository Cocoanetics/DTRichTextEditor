//
//  DTRichTextEditorContentView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTAttributedTextContentView.h>

/**
 This class represents the content view of a DTRichTextEditorView which itself is a UIScrollView subclass.
 
 It adds mutability and incremental layouting to DTAttributedTextContentView.
 */
@interface DTRichTextEditorContentView : DTAttributedTextContentView

/**
 @name Layout
 */

/**
 Recalculates the layout for the paragraphs covered by the given range.
 @param range The string strange to relayout.
 */
- (void)relayoutTextInRange:(NSRange)range;

/**
 @name Modifying the Content
 */

/**
 Replaces the attributed text in the given range.
 @param range The string range to replace
 @param text The replacement text
 */
- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text;

@end
