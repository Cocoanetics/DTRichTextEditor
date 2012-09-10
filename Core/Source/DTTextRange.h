//
//  DTRichTextRange.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTTextPosition.h"

@interface DTTextRange : UITextRange <NSCopying>
{
	DTTextPosition *_start;
	DTTextPosition *_end;
}


+ (DTTextRange *)textRangeFromStart:(UITextPosition *)start toEnd:(UITextPosition *)end;
//+ (DTTextRange *)textRangeFromStartLocation:(NSInteger)start toEndLocation:(NSInteger)end;

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


- (NSRange)NSRangeValue;
- (NSUInteger)length;

//- (DTTextPosition *)start;
//- (DTTextPosition *)end;


@end
