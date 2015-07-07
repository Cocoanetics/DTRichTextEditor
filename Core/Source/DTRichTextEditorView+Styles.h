//
//  DTRichTextEditorView+Styles.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 16.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView.h"
#import <DTCoreText/DTCoreTextFontDescriptor.h>
#import <DTCoreText/DTCoreTextParagraphStyle.h>
#import <DTCoreText/DTCSSListStyle.h>

/**
 The **Ranges** category enhances DTRichTextEditorView with methods for retrieving CSS-like style information.
 */
@interface DTRichTextEditorView (Styles)

/**
 @name Getting Style Information
 */

/**
 Determines the Core Text attributes for the text defaults currently set on the receiver.
 
 @returns An attribute dictionary suitable for constructing default text
 */
- (NSDictionary *)attributedStringAttributesForTextDefaults;

/**
 Retrieves the `NSAttributedString` attributes for a given tag name, considering overrides specified via textDefaults
 
 The relativeToTextSize is needed because some styles sizings depend on the current text size, e.g. `0.8em`
 
 @param tagName The tag name to retrieve a attributes for
 @param tagClass The tag class, or `nil`
 @param tagIdentifier The tag id or `nil`
 @param textSize The text size to use for relative measurements
 @returns The attributes dictionary
 */
- (NSDictionary *)attributesForTagName:(NSString *)tagName tagClass:(NSString *)tagClass tagIdentifier:(NSString *)tagIdentifier relativeToTextSize:(CGFloat)textSize;

/**
 Retrieves the list indent from the leading margin to apply for a given list style
 
 This value is determined by parsing a single character HTML with the appropriate list HTML and takes the textDefaults into consideration.
 @param listStyle The CSS list style to determine the list indentation for
 @returns The indent or 0 if listStyle is `nil`
 */
- (CGFloat)listIndentForListStyle:(DTCSSListStyle *)listStyle;

/**
 Retrieves a font descriptor for the default font, considering overrides specified via textDefaults
 @returns A font descriptor
 */
- (DTCoreTextFontDescriptor *)defaultFontDescriptor;

@end
