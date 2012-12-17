//
//  DTRichTextEditorView+Manipulation.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView.h"

@class DTTextRange, DTTextPosition, DTCSSListStyle;

/**
 This category enhances DTRichTextEditorView with useful text format manipulation methods.
 */
@interface DTRichTextEditorView (Manipulation)

- (UITextRange *)rangeForWordAtPosition:(UITextPosition *)textPosition;

/**
 The attributes to apply for new text inserted at the given range.
 */
- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;

- (NSDictionary *)defaultAttributes;
- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;
- (UITextRange *)textRangeOfURLAtPosition:(UITextPosition *)position URL:(NSURL **)URL;

- (void)replaceRange:(UITextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

- (void)toggleBoldInRange:(UITextRange *)range;
- (void)toggleItalicInRange:(UITextRange *)range;
- (void)toggleUnderlineInRange:(UITextRange *)range;

- (void)toggleHighlightInRange:(UITextRange *)range color:(UIColor *)color;

// make a range a hyperlink or remove it
- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL;

- (void)applyTextAlignment:(CTTextAlignment)alignment toParagraphsContainingRange:(UITextRange *)range;
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range;

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;

- (NSString *)plainTextForRange:(UITextRange *)range;

- (void)setHTMLString:(NSString *)string;

// pasteboard

- (BOOL)pasteboardHasSuitableContentForPaste;


@end
