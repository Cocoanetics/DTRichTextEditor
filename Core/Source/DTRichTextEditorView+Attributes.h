//
//  DTRichTextEditorView+Attributes.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/3/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView.h"

/**
 The **Attributes** category contains methods to support custom HTML attributes.
 */

@interface DTRichTextEditorView (Attributes)


/**
 @name Querying Custom HTML Attributes
 */

/**
 Retrieves the dictionary of custom HTML attributes active at the given string index
 @param position The text position to query
 @returns The custom HTML attributes dictionary or `nil` if there aren't any at this index
 */
- (NSDictionary *)HTMLAttributesAtPosition:(UITextPosition *)position;

/**
 Retrieves the range that an attribute with a given name is active for, beginning with the passed index
 
 Since a custom HTML attribute can occur in multiple individual attribute dictionaries this extends the range from the passed index outwards until the full range of the custom HTML attribute has been found. Those range extentions have to have an identical value, as established by comparing them to the value of the custom attribute at the index with isEqual:
 @param name The name of the custom HTML attribute to query
 @param position The text position to query
 @returns The custom HTML attributes dictionary or `nil` if there aren't any at this index
 */
- (NSRange)rangeOfHTMLAttribute:(NSString *)name atPosition:(UITextPosition *)position;


/**
 @name Modifying Custom HTML Attributes
 */

/**
 Adds the custom HTML attributes with the given value on the given range, optionally replacing occurences of an attribute with the same name.
 @param name The name of the custom HTML attribute
 @param value The value to set for the custom attribute
 @param range The text range to set the custom attribute on
 @param replaceExisting `YES` if ranges that have an attribute with the same name should be replaced. With `NO` the attribute is only added for ranges where there is no attribute with the given name
 */
- (void)addHTMLAttribute:(NSString *)name value:(id)value range:(UITextRange *)range replaceExisting:(BOOL)replaceExisting;

/**
 Adds the custom HTML attributes with the given value from the given range.
 @param name The name of the custom HTML attribute
 @param range The text range to remove the custom attribute from
 */
- (void)removeHTMLAttribute:(NSString *)name range:(UITextRange *)range;

@end
