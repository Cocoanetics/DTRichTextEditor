//
//  NSMutableDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSDictionary+DTRichText.h"

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
 Updates the font attribute via a font descriptor
 @param fontDescriptor The font descriptor which describes the font to set
 */
- (void)setFontFromFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor;

/**
 Toggles the background color to the given color. If the attributes are already containing a highlight then it is removed
 @param color The color to highlight with. If there is a previous highlight then this parameter is ignored
 */
- (void)toggleHighlightWithColor:(UIColor *)color;

/**
 Removes the attributes related to a DTTextAttachment from the receiver
 */
- (void)removeAttachment;

@end
