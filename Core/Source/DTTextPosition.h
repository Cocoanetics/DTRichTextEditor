//
//  DTTextPosition.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKIt.h>

/**
 Class to represent a text position in DTRichTextEditorView
 */
@interface DTTextPosition : UITextPosition <NSCopying>

/**
 @name Creating Text Positions
 */

/**
 Convenience method for created a text position from a string location.
 @param location The string location
 @returns An initialized text position
 */
+ (DTTextPosition *)textPositionWithLocation:(NSUInteger)location;

/**
 Creates a new text position that is offset from the receiver's location.
 @param offset The offset to apply to the receiver's location
 @returns An initialized text position with the given offset
 */
- (DTTextPosition *)textPositionWithOffset:(NSInteger)offset;


/**
 @name Comparing Text Positions
 */

/**
 Compares the receiver to another text position
 @param otherPosition The other text position to compare with
 @returns An `NSComparisonResult`
 */
- (NSComparisonResult)compare:(UITextPosition *)otherPosition;

/**
 Compares the receiver to another text position
 @param otherPosition The other text position to compare with
 @returns `YES` if both are equivalent
 */
- (BOOL)isEqual:(UITextPosition *)otherPosition;


/**
 @name Getting Information about Text Positions
 */

/**
 The string index location
 */
@property (nonatomic, readonly) NSUInteger location;

@end
