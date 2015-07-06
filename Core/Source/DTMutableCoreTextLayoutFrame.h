//
//  DTMutableCoreTextLayoutFrame.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/23/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreTextLayoutFrame.h>

/**
 Mutable subclass of <DTCoreTextLayoutFrame> to allow editing
 */
@interface DTMutableCoreTextLayoutFrame : DTCoreTextLayoutFrame

/**
 @name Creating Mutable Layout Frames
 */

/**
 Default initializer.
 @param frame The frame that is available for text
 @param attributedString The attributed string to fill the receiver with
 @returns An initialized mutable layout frame
 */
- (id)initWithFrame:(CGRect)frame attributedString:(NSAttributedString *)attributedString;

/**
 @name Incremental Layouting
 */

/**
 Re-layouts the text contents of the receiver and adjusts the frame to match the contents
 */
- (void)relayoutText;

/**
 Relayouts the text in the given string range
 @param range The string range to redo layout for
 @note This method might be defunct as all incremental layouting uses replaceTextRange:withText:directRect: at present.
 */
- (void)relayoutTextInRange:(NSRange)range;


/**
 Replaces the attributed text in the given range with new text and optionally returns the dirty rectangle this change has caused.
 @param range The string range to replace
 @param text The text to replace the range with
 @param dirtyRect Output param to receive the dirtyRect or `NULL` if this is not required
 */
- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text dirtyRect:(CGRect *)dirtyRect;


/**
 @name Properties
 */

/**
 Specifies if the next time the frame of the receiver is modified it should also do a layout pass.
 
 Defaults to `YES`
 */
@property (nonatomic, assign) BOOL shouldRebuildLines;

/**
 Modifies the text frame of the receiver. 
 
 Set <shouldRebuildLines> to `NO` to avoid relayouting text on a frame change
 @param frame The new frame
 */
- (void)setFrame:(CGRect)frame;

/**
 Replaces the text contents of the receiver
 @param attributedString The new attributed string
 */
- (void)setAttributedString:(NSAttributedString *)attributedString;


@end
