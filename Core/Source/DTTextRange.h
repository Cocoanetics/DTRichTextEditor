//
//  DTRichTextRange.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTTextPosition.h"

/**
 This class represents a range of text in an <DTRichTextEditorView>. It is a concrete subclass of `UITextRange`.
 
 A range is considered empty if start is equal to end because the length generally does not include the ending character, similar to a caret being position on the index of the ending character.
 */
@interface DTTextRange : UITextRange <NSCopying>

/**
 @name Creating Text Ranges
 */

/**
 Convenience method to create a text range from a start and end position
 @param start The starting position
 @param end The ending position
 @returns A text range with those positions as end points
 */
+ (DTTextRange *)textRangeFromStart:(UITextPosition *)start toEnd:(UITextPosition *)end;

/**
 Creates an empty text range with position.
 @param position a DTTextPosition
 @param offset An offset to add to the location
 @returns The new text range
 */
+ (DTTextRange *)emptyRangeAtPosition:(UITextPosition *)position offset:(NSInteger)offset;

/**
 Creates an empty text range with position.
 @param position a DTTextPosition
 @returns The new text range
 */
+ (DTTextRange *)emptyRangeAtPosition:(UITextPosition *)position;

/**
 Creates a text range from an NSRange.
 @param range The NSRange to convert to a DTTextRange
 @returns The new text range
 */
+ (DTTextRange *)rangeWithNSRange:(NSRange)range;


/**
 @name Getting Information about Text Ranges
 */

/**
 Retrieves the NSRange value of the receiver
 @returns The range value
 */
- (NSRange)NSRangeValue;

/**
 The length of the string range represented by the receiver
 */
- (NSUInteger)length;

@end
