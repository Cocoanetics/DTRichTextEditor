//
//  DTCoreTextLayoutFrame+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/25/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTCoreTextLayoutFrame.h"

@class DTTextPosition, DTTextRange;

@interface DTCoreTextLayoutFrame (DTRichText)

- (CGRect)firstRectForRange:(NSRange)range;
- (NSArray *)selectionRectsForRange:(NSRange)range;

- (NSInteger)indexForPositionUpwardsFromIndex:(NSInteger)index offset:(NSInteger)offset;
- (NSInteger)indexForPositionDownwardsFromIndex:(NSInteger)index offset:(NSInteger)offset;

- (NSInteger)closestIndexToPoint:(CGPoint)point;
- (NSInteger)closestCursorIndexToPoint:(CGPoint)point;
- (CGRect)cursorRectAtIndex:(NSInteger)index;

@end
