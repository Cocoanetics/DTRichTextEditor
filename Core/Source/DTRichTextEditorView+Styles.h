//
//  DTRichTextEditorView+Styles.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 16.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"

/**
 The **Ranges** category enhances DTRichTextEditorView with methods for retrieving CSS-like style information.
 */
@interface DTRichTextEditorView (Styles)


/**
 Determines the Core Text attributes for the text defaults currently set on the receiver.
 
 @returns An attribute dictionary suitable for constructing default text
 */
- (NSDictionary *)attributedStringAttributesForTextDefaults;


/**
 Retrieves the list indent from the leading margin to apply for a given list style
 
 This value is determined by parsing a single character HTML with the appropriate list HTML and takes the textDefaults into consideration.
 @returns The indent or 0 if listStyle is `nil`
 */
- (CGFloat)listIndentForListStyle:(DTCSSListStyle *)listStyle;


- (CGFloat)textSizeAtPosition:(UITextPosition *)position;

/**
 Retrieves the paragraph style to apply for a given tag name, considerting textDefaults
 
 @param tagName The tag name to retrieve a style for
 @param tagClass The tag class, or `nil`
 @param tagIdentifier The tag id or `nil`
 @returns The paragraph style to use for this kind of tag
 */
- (DTCoreTextParagraphStyle *)paragraphStyleForTagName:(NSString *)tagName tagClass:(NSString *)tagClass tagIdentifier:(NSString *)tagIdentifier relativeToTextSize:(CGFloat)textSize;

@end
