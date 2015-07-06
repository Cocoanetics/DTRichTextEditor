//
//  DTCoreTextLayoutFrame+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/25/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreTextLayoutFrame.h>

@class DTTextPosition, DTTextRange;

/**
 Methods that extend DTCoreTextLayoutFrame for use by editors.
 */
@interface DTCoreTextLayoutFrame (DTRichText)

/**
 A rectangle starting encompassing the range, or first line whichever is smaller
 @param range The string range
 @returns The rectangle
 */
- (CGRect)firstRectForRange:(NSRange)range;

/**
 The selection rects for a given range, represented as DTTextSelectionRect instances.
 @param range The string range
 @returns An arrow of the selection rects
 */
- (NSArray *)selectionRectsForRange:(NSRange)range;

/**
 Determines the string index you arrive at if you start at a given index and to a certain number of lines upwards.
 @param index The index to start at
 @param offset The number of lines to move upwards
 @returns The resulting string index
 */
- (NSInteger)indexForPositionUpwardsFromIndex:(NSInteger)index offset:(NSInteger)offset;

/**
 Determines the string index you arrive at if you start at a given index and to a certain number of lines downwards.
 @param index The index to start at
 @param offset The number of lines to move downwards
 @returns The resulting string index
 */
- (NSInteger)indexForPositionDownwardsFromIndex:(NSInteger)index offset:(NSInteger)offset;

@end
