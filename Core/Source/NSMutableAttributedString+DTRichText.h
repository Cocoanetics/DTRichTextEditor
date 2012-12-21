//
//  NSMutableAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTCoreText.h"

@class DTTextAttachment;

// block used for enumerating paragraph styles
typedef BOOL (^NSMutableAttributedStringParagraphStyleEnumerationBlock)(DTCoreTextParagraphStyle *paragraphStyle, BOOL *stop);

// block used for enumerating font styles
typedef BOOL (^NSMutableAttributedStringFontStyleEnumerationBlock)(DTCoreTextFontDescriptor *fontDescriptor, BOOL *stop);

@interface NSMutableAttributedString (DTRichText)

// convenience method to insert an attachment
// returns the length of the replacement string
- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

// convenience methods to toggline simple styles
- (void)toggleBoldInRange:(NSRange)range;
- (void)toggleItalicInRange:(NSRange)range;
- (void)toggleUnderlineInRange:(NSRange)range;

// text highlighting
- (void)toggleHighlightInRange:(NSRange)range color:(UIColor *)color;

// adding/removing hyperlinks
- (void)toggleHyperlinkInRange:(NSRange)range URL:(NSURL *)URL;

/**
 Replacing the `UIFont` for a range
 @param range The range to repace the font in
 */
- (void)replaceFont:(UIFont *)font inRange:(NSRange)range;

/**
 Enumerates the paragraph styles for a given range extended to contain full paragraphs. If the block returns `YES` then the paragraph style for the paragraph is updated with changes made to the paragraphStyle parameter.
 @param range The range to update
 @param block The block to execute for each paragraph
 @returns `YES` if at least one paragraph has been updated
 */
- (BOOL)enumerateAndUpdateParagraphStylesInRange:(NSRange)range block:(NSMutableAttributedStringParagraphStyleEnumerationBlock)block;

/**
 Enumerates the font styles for a given range. If the block returns `YES` then the font will be updated with changes made to the fontDescriptor parameter.
 Note: This does not extend the range to include full paragraphs as enumerateAndUpdateParagraphStylesInRange:block: does.
 @param range The range to update
 @param block The block to execute for each font range
 @returns `YES` if at least one font has been updated
 */
- (BOOL)enumerateAndUpdateFontInRange:(NSRange)range block:(NSMutableAttributedStringFontStyleEnumerationBlock)block;

// convenience method to toggle list on entire paragraphs
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(NSRange)range numberFrom:(NSInteger)nextItemNumber;

// sets or removes the space following the paragraph at the given index
- (void)toggleParagraphSpacing:(BOOL)spaceOn atIndex:(NSUInteger)index;

// method to correct paragraph styles on paragraphs belonging to list
- (void)correctParagraphSpacingForRange:(NSRange)range;

// Adding/removing a marked range
- (void)addMarkersForSelectionRange:(NSRange)range;
- (NSRange)markedRangeRemove:(BOOL)remove;

@end
