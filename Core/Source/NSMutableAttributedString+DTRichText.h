//
//  NSMutableAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

@class DTTextAttachment, DTCoreTextParagraphStyle, DTCoreTextFontDescriptor;

/**
 Block used for enumerating paragraph styles
 */
typedef BOOL (^NSMutableAttributedStringParagraphStyleEnumerationBlock)(DTCoreTextParagraphStyle *paragraphStyle, BOOL *stop);

/**
 Block used for enumerating font styles
 */
typedef BOOL (^NSMutableAttributedStringFontStyleEnumerationBlock)(DTCoreTextFontDescriptor *fontDescriptor, BOOL *stop);

/**
 Methods extensing `NSMutableAttributedString` for use with editors
 */
@interface NSMutableAttributedString (DTRichText)

/**
 @name Modifying Text
 */

/**
 Convenience method to insert a DTTextAttachment.
 @param range The string range to insert the attachment at
 @param attachment The text attachment to insert
 @param inParagraph `YES` if the attachment should be placed in its own paragraph, `NO` to place it inline
 @returns The length of the replacement string to allow for moving the cursor appropriately
 */
- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

/**
 @name Toggling Styles
 */

/**
 Toggles the given string range between bold and non-bold.
 @param range The affected string range
 */
- (void)toggleBoldInRange:(NSRange)range;

/**
 Toggles the given string range between italic and non-italic.
 @param range The affected string range
 */
- (void)toggleItalicInRange:(NSRange)range;

/**
 Toggles the given string range between underline and non-underline.
 @param range The affected string range
 */
- (void)toggleUnderlineInRange:(NSRange)range;

/**
 Toggles the given string range between strikethrough and non-strikethrough.
 @param range The affected string range
 */
- (void)toggleStrikethroughInRange:(NSRange)range;

/**
 Toggles the given string range between highlighted and non-highlighted.
 
The color parameter is ignored if the method call toggles a previous URL off.
 @param range The affected string range
 @param color The color to apply for the highlight
 */
- (void)toggleHighlightInRange:(NSRange)range color:(UIColor *)color;

/**
 Sets the text foreground color.
 @param range The affected string range
 @param color The color to apply for the foreground color, or `nil` to restore the default black color
 */
- (void)setForegroundColor:(UIColor *)color inRange:(NSRange)range;

/**
 Toggles the given string range between having a hyperlink and not
 
 The URL parameter is ignored if the method call toggles a previous URL off.
 @param range The affected string range
 @param URL The hyperlink URL to apply for the string
 */
- (void)toggleHyperlinkInRange:(NSRange)range URL:(NSURL *)URL;


/**
 @name Working with Fonts
 */

/**
 Replacing the `UIFont` for a range
 @param range The range to repace the font in
 @param font The replacement front
 */
- (void)replaceFont:(UIFont *)font inRange:(NSRange)range;

/**
 Enumerates the font styles for a given range. If the block returns `YES` then the font will be updated with changes made to the fontDescriptor parameter.
 Note: This does not extend the range to include full paragraphs as enumerateAndUpdateParagraphStylesInRange:block: does.
 @param range The range to update
 @param block The block to execute for each font range
 @returns `YES` if at least one font has been updated
 */
- (BOOL)enumerateAndUpdateFontInRange:(NSRange)range block:(NSMutableAttributedStringFontStyleEnumerationBlock)block;

/**
 @name Working with Paragraph Styles
 */

/**
 Enumerates the paragraph styles for a given range extended to contain full paragraphs. If the block returns `YES` then the paragraph style for the paragraph is updated with changes made to the paragraphStyle parameter.
 @param range The range to update
 @param block The block to execute for each paragraph
 @returns `YES` if at least one paragraph has been updated
 */
- (BOOL)enumerateAndUpdateParagraphStylesInRange:(NSRange)range block:(NSMutableAttributedStringParagraphStyleEnumerationBlock)block;

/**
 Sets or removes the space following the paragraph at the given index
 @param spaceOn If yes then the default paragraph space is added
 @param spacing When toggling spacing on this is the spacing to apply
 @param index The string index in the affected paragraph
 */
- (void)toggleParagraphSpacing:(BOOL)spaceOn atIndex:(NSUInteger)index spacing:(CGFloat)spacing;

/** 
 Method to correct paragraph styles on paragraphs belonging to list
 @note List support is not complete
 */
- (void)correctParagraphSpacing;

/**
 @name Working with Lists
 */

/**
 Convenience method to update list styling on entire paragraphs
 
 @param listStyle The list style to apply or `nil` to remove list styling
 @param range The range to update
 @param nextItemNumber For numbered lists this is the next number to use
 @param listIndent The indent from leading margin to indent list paragraphs at
 @param spacingAfterList The spacing to apply on the last paragraph of the list
 @param removeNonPrefixed Whether paragraphs that have no list prefix should be removed from lists
 */
- (void)updateListStyle:(DTCSSListStyle *)listStyle inRange:(NSRange)range numberFrom:(NSInteger)nextItemNumber listIndent:(CGFloat)listIndent spacingAfterList:(CGFloat)spacingAfterList removeNonPrefixedParagraphsFromList:(BOOL)removeNonPrefixed;

/**
 Deletes a list prefix from the receiver if there is one.
 @returns `YES` if a list prefix field was deleted, `NO` if there was no prefix
 */
- (BOOL)deleteListPrefix;

/**
 @name Marking Ranges
 */

/**
 Adding a marked range
 @param range The affected string range
 */
- (void)addMarkersForSelectionRange:(NSRange)range;

/**
 Removing the marking from a marked range
 @param remove `YES` if the marking should be cleared
 @returns The range that is marked
 */
- (NSRange)markedRangeRemove:(BOOL)remove;

@end
