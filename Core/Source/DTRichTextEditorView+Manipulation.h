//
//  DTRichTextEditorView+Manipulation.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTCoreText/DTCoreTextGlyphRun.h>

#import "DTRichTextEditorView.h"

/**
 Options for generating HTML output
 */
typedef NS_ENUM(NSUInteger, DTHTMLWriterOption)
{
   /**
    HTML output as document-style, with CSS styles compressed in header
    */
	DTHTMLWriterOptionDocument = 0,  // default
   
   /**
    HTML output as fragment, CSS styles inlined
    */
	DTHTMLWriterOptionFragment = 1 << 0
};


@class DTTextRange, DTTextPosition, DTCSSListStyle, DTCoreTextFontDescriptor;

/**
 The **Manipulation** category enhances DTRichTextEditorView with useful text format manipulation methods.
 */
@interface DTRichTextEditorView (Manipulation)

/**
 @name Getting/Setting Content
 */

/**
 Retrieves that attributed substring for the given range.
 @param range The text range
 @returns The `NSAttributedString` substring
 */
- (NSAttributedString *)attributedSubstringForRange:(UITextRange *)range;


/**
 Retrieves the glyph run around the given text location. This is useful to inspect the actually used attributes. For example you can get the actual writing direction or the actually used font used.
 @param position The text position
 @returns The DTCoreTextGlyphRun object with all glyphs having the same attributes
 */
- (DTCoreTextGlyphRun *)glyphRunAtPosition:(UITextPosition *)position;

/**
 Prepares a plain-text representation of the substring for the given range.
 
 If the attributed string in this range contains attachments then those are removed.
 @param range The text range.
 @returns A substring of the receivers current contents
 */
- (NSString *)plainTextForRange:(UITextRange *)range;

/**
 The attributes to apply for new text inserted at the given range.
 @param range The text range
 @returns The dictionary of styles
 */
- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;

/**
 Temporary storage for typing attributes if there is no range to apply them to, e.g. for a zero-length selection. To retrieve the current typing attributes you should first inspect this property and if it is `nil` retrieve the typingAttributesForRange: for the current selected text range.
 */
@property (nonatomic, retain) NSDictionary *overrideInsertionAttributes;

/**
 Converts the given string to an `NSAttributedString` using the current textDefaults and sets it on the receiver.
 @param string The string containing HTML text to convert to an attributed string and set as content of the receiver
 */
- (void)setHTMLString:(NSString *)string;

/**
 Converts the current attributed string contents of the receiver to an HTML string.
 
 This uses DTHTMLWriter and uses the currently set textScale to reverse font scale changes. This allows for HTML with a small font size to be displayed at a larger font size, but the generated HTML will still have the original font size.
 
 Valid options are:
 
 - 	DTHTMLWriterOptionDocument: Styles are compressed into a stylesheet and a header is output (default)
 -  DTHTMLWriterOptionFragment: All styles are inline and no header is output
 
 @param options The options to apply for the conversion.
 @returns An `NSString` with a generated HTML representation of the text
 */
- (NSString *)HTMLStringWithOptions:(DTHTMLWriterOption)options;

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
 Apples a given header level to the given range. The range is extended to include full paragraphs. 
 
 If the range belongs to a list then it is removed from the list. All existing attributes are replaced.
 
 @param headerLevel The header level (1-6) to set or 0 to restore normal paragraph style
 @param range The text range
 */
- (void)updateHeaderLevel:(NSUInteger)headerLevel inRange:(UITextRange *)range;

/**
 @name Toggling Styles for Ranges
 */

/**
 Toggles bold font style on the given range. 
 
 The first character of the range determines if the range is to be treated as bold or not.
 @param range The text range
 */
- (void)toggleBoldInRange:(UITextRange *)range;

/**
 Toggles italic font style on the given range.
 
 The first character of the range determines if the range is to be treated as italic or not.
 @param range The text range
 */
- (void)toggleItalicInRange:(UITextRange *)range;

/**
 Toggles underline font style on the given range.
 
 The first character of the range determines if the range is to be treated as underlined or not.
 @param range The text range
 */
- (void)toggleUnderlineInRange:(UITextRange *)range;

/**
 Toggles strikethrough font style on the given range.
 
 The first character of the range determines if the range is to be treated as strikethrough or not.
 @param range The text range
 */
- (void)toggleStrikethroughInRange:(UITextRange *)range;


/**
 Highlights a given range.
 
 The first character of the range determines if the range is to be treated as already highlighted or not.
 @param color The highlight color to mark the range with. If the range is already marked then this parameter is ignored.
 @param range The text range
 */
- (void)toggleHighlightInRange:(UITextRange *)range color:(UIColor *)color;

/**
 Sets the text foreground color for a given range.
 @param color The foreground color to set. Passing `nil` removes the color attribute and thus restores the black default color.
 @param range The text range
 */
- (void)setForegroundColor:(UIColor *)color inRange:(UITextRange *)range;

/**
 Toggles a hyperlink on the given range.
 
 The first character of the range determines if the range is to be treated as already hyperlinked or not.
 @param range The text range
 @param URL The hyperlink URL to set on the range with. If the range already has a hyperlink then this parameter is ignored.
 */
- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL;


/**
 @name Working with Fonts
 */

/**
 Replaces the font for a given range preserving bold or italic ranges.
 @param range The text range
 @param fontFamilyName The postscript font family name, or `nil` if the font family should be preserved.
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
