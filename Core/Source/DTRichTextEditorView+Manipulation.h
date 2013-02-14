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

/**
 @name Getting/Setting Content
 */

/**
 Retrieves that attributed substring for the given range.
 @param range The text range.
 @returns The `NSAttributedString` substring
 */
- (NSAttributedString *)attributedSubstringForRange:(UITextRange *)range;

/**
 Prepares a plain-text representation of the substring for the given range.
 
 If the attributed string in this range contains attachments then those are removed.
 @returns A substring of the receivers current contents
 */
- (NSString *)plainTextForRange:(UITextRange *)range;

/**
 Converts the given string to an `NSAttributedString` using the current textDefaults and sets it on the receiver.
 */
- (void)setHTMLString:(NSString *)string;


/**
 @name Working with Ranges
 */

/**
 Gets the text range of an URL at the given text position. Optionally also returns the hyperlink URL.
 @param position The text position
 @param URL An optional URL output param or `NULL` if the URL is not required
 @returns the text range or `NULL` if there is no URL at this position
 */
- (UITextRange *)textRangeOfURLAtPosition:(UITextPosition *)position URL:(NSURL **)URL;

/**
 Gets the range that encompasses the word at the given text position.
 @param position The text position
 @returns the text range
 */
- (UITextRange *)textRangeOfWordAtPosition:(UITextPosition *)position;

/**
 The attributes to apply for new text inserted at the given range.
 @param range The text range
 @returns The dictionary of styles
 */
- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;

/**
 Extends the given range to include all full paragraphs that contain it.
 @param range The text range
 @returns The extended range
 */
- (UITextRange *)textRangeOfParagraphsContainingRange:(UITextRange *)range;


/**
 @name Changing Paragraph Styles
 */

/**
 Applies the given text alignment to all paragraphs that are encompassing the given text range.
 @param alignment The text alignment to apply
 @param range The text range
 @returns `YES` if at least one paragraph's alignment was changed
 */
- (BOOL)applyTextAlignment:(CTTextAlignment)alignment toParagraphsContainingRange:(UITextRange *)range;

/**
 Changes the paragraph indentation by the given amount.
 
 This modifies both the firstLineHeadIndent as well as the headIndent properties of the paragraph styles.
 @param range The text range
 @param delta The amont to modify the left indentation by.
 */
- (void)changeParagraphLeftMarginBy:(CGFloat)delta toParagraphsContainingRange:(UITextRange *)range;

/**
 Toggles a list style on a given range.
 @param listStyle the list style to toggle
 @param range The text range
*/
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range;

/**
 @name Toggling Styles for Ranges
 */

/**
 Toggles bold font style on the given range. 
 
 The first character of the range determins if the range is to be treated as bold or not.
 @param range The text range
 */
- (void)toggleBoldInRange:(UITextRange *)range;

/**
 Toggles italic font style on the given range.
 
 The first character of the range determins if the range is to be treated as italic or not.
 @param range The text range
 */
- (void)toggleItalicInRange:(UITextRange *)range;

/**
 Toggles underline font style on the given range.
 
 The first character of the range determins if the range is to be treated as underlined or not.
 @param range The text range
 */
- (void)toggleUnderlineInRange:(UITextRange *)range;

/**
 Highlights a given range.
 
 The first character of the range determins if the range is to be treated as already highlighted or not.
 @param range The text range
 */
- (void)toggleHighlightInRange:(UITextRange *)range color:(UIColor *)color;

/**
 Toggles a hyperlink on the given range.
 
 The first character of the range determins if the range is to be treated as already hyperlinked or not.
 @param range The text range
 */
- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL;

/**
 @name Working with Fonts
 */

/**
 Replaces the font for a given range preserving bold or italic ranges.
 @param range The text range
 @param fontName The postscript font family name, or `nil` if the font family should be preserved.
 @param pointSize The point size in pixels to apply, or 0 if it should be preserved
*/
- (void)updateFontInRange:(UITextRange *)range withFontFamilyName:(NSString *)fontFamilyName pointSize:(CGFloat)pointSize;

/**
 Returns a font descriptor that matches the font at the given range. The method calls typingAttributesForRange: and converts the font to a font descriptor.
 If the range is empty then the font matches what it would be if the user would start typing. If the range is not empty then it is the font of the first character in the range. 
 @param range The text range in the attributed string for which to query the font
 @returns The font descriptor
 */
- (DTCoreTextFontDescriptor *)fontDescriptorForRange:(UITextRange *)range;

/**
 Convenience method to set the defaultFontFamily and defaultFontSize to the given font's values. Updates the entire string with this.
 @param font The font to use the values from
 */
- (void)setFont:(UIFont *)font;

/**
 @name Working with Attachments
 */

/**
 Inserts an attachment in the given text range.
 @param range The text range for the insertion
 @param attachment The text attachment to be inserted
 @param inParagraph If `YES` then the method makes sure that the attachment sits in its own paragraph
 */
- (void)replaceRange:(UITextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

/**
 Retrieving the attachments that match a predicate.
 @param predicate The `NSPredicate` that will be used to check the DTTextAttachment key values against
 @returns An array of matching attachments
 */
- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;

 
/**
 @name Interacting With The Pasteboard
 */

/**
 Determines if there is something on the pasteboard that can be pasted into the receiver.
 @returns `YES` if something can be pasted
 */
- (BOOL)pasteboardHasSuitableContentForPaste;


@end
