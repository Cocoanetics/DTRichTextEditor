//
//  NSMutableAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTCoreText.h"

@class DTTextAttachment;

@interface NSMutableAttributedString (DTRichText)

// convenience method to insert an attachment
// returns the length of the replacement string
- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

// convenience methods to toggline simple styles
- (void)toggleBoldInRange:(NSRange)range;
- (void)toggleItalicInRange:(NSRange)range;
- (void)toggleUnderlineInRange:(NSRange)range;

// convenience method to set text alignment on entire paragraphs
- (void)adjustTextAlignment:(CTTextAlignment)alignment inRange:(NSRange)range;

// convenience method to toggle list on entire paragraphs
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(NSRange)range numberFrom:(NSInteger)nextItemNumber;

// sets or removes the space following the paragraph at the given index
- (void)toggleParagraphSpacing:(BOOL)spaceOn atIndex:(NSUInteger)index;

// method to correct paragraph styles on paragraphs belonging to list
- (void)correctParagraphSpacingForRange:(NSRange)range;

@end
