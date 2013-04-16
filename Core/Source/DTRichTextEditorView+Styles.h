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

@end
