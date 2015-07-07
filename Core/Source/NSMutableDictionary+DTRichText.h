//
//  NSMutableDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCoreTextFontDescriptor;

/**
 Convenience methods to execute typical editing actions on a CoreText attribute dictionary.
 */
@interface NSMutableDictionary (DTRichText)

/**
 Toggle the attributes in the receiver bold. If font is already bold then it will be made normal.
 */
- (void)toggleBold;

/**
 Toggle the attributes in the receiver italic. If font is already italic then it will be made normal.
 */
- (void)toggleItalic;

/**
 Toggle the attributes in the receiver underline. If text is already marked as underline then the underline is removed.
 */
- (void)toggleUnderline;

/**
 Toggle the attributes in the receiver strikethrough. If text is already marked as strikethrough then the strikethrough is removed.
 */
- (void)toggleStrikethrough;

/**
 Updates the font attribute via a font descriptor
 @param fontDescriptor The font descriptor which describes the font to set
 */
- (void)setFontFromFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor;

/**
 Updates the paragraph spacing to a given amount
 @param paragraphSpacing The new space after paragraphs to apply
 */
- (void)updateParagraphSpacing:(CGFloat)paragraphSpacing;


/**
 Toggles the background color to the given color. If the attributes are already containing a highlight then it is removed
 @param color The color to highlight with. If there is a previous highlight then this parameter is ignored
 */
- (void)toggleHighlightWithColor:(UIColor *)color;

/**
 Sets the text foreground color to the given color. 
 @param color The color to set or `nil` to restore the default black text color
 */
- (void)setForegroundColor:(UIColor *)color;

/**
 Removes the attributes related to a DTTextAttachment from the receiver
 */
- (void)removeAttachment;

/**
 Removes the underline style from the receiver
 */
- (void)removeUnderlineStyle;

/**
 Removes list prefix field from the receiver
 */
- (void)removeListPrefixField;

@end
