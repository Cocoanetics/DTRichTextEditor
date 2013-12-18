//
//  DTTextSelectionView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/7/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The type of a selection
 */
typedef NS_ENUM(NSUInteger, DTTextSelectionStyle)
{
   /**
    Selection is a regular selection range
    */
	DTTextSelectionStyleSelection = 0,
   
   /**
    Selection is marking range, as for multi-stage text input
    */
	DTTextSelectionStyleMarking
};

@class DTTextSelectionView;


/**
 A view that shows selection rectangles for an editor.
 */
@interface DTTextSelectionView : UIView

/**
 @name Creating a Selection View
 */

/**
 Designated Initializer. Creates a selection view for a given text view
 
 @param view The text view that this selection view shows selections for
 @returns An initialized selection view
 */
- (id)initWithTextView:(UIView *)view;

/**
 @name Accessing Subviews
 */

/**
 The text view that the receiver belongs to
 */
@property (nonatomic, readonly) UIView *textView;

/**
 The image view that represents the left drag handle. 
 */
@property (nonatomic, retain) UIImageView *dragHandleLeft;

/**
 The image view that represents the right drag handle.
 */
@property (nonatomic, retain) UIImageView *dragHandleRight;

/**
 @name Customizing the Look
 */

/**
 The current selection style of the receiver.
 
 Support are blue selection and green marking style.
 
 - DTTextSelectionStyleSelection
 - DTTextSelectionStyleMarking
 */
@property (nonatomic, assign) DTTextSelectionStyle style;

/**
 The caret color to use next to the ranged selection drag handles
 */
@property (nonatomic, retain) UIColor *cursorColor;

/**
 @name Working with Selection Rectangles
 */

/**
 The selection rectangles to display in the receiver
 */
@property (nonatomic, retain) NSArray *selectionRectangles;


/**
 Customized setter for selectionRectangles that optionally animates the selection change
 @param selectionRectangles The selection rectangles to set
 @param animated Whether the change of selection rectangles should be animated
 */
- (void)setSelectionRectangles:(NSArray *)selectionRectangles animated:(BOOL)animated;


/**
 @name Working with Drag Handles
 */

/**
 Specifies whether the drag handles are visible
 */
@property (nonatomic, assign) BOOL dragHandlesVisible;

/**
 Customized setter to optionally show/hide the drag handles with a fading animation
 @param dragHandlesVisible `YES` to make the drag handles visible, `NO` to hide them
 @param animated Whether the change of visibility of the drag handles should be animated
 */
- (void)setDragHandlesVisible:(BOOL)dragHandlesVisible animated:(BOOL)animated;

/**
 @name Getting Information
 */

/**
 The frame rectangle of the beginning caret of a selected range
 */
- (CGRect)beginCaretRect;

/**
 The frame rectangle of the ending caret of a selected range
 */
- (CGRect)endCaretRect;

/**
 A frame rectangle the envelops the entire selection

 */
- (CGRect)selectionEnvelope;


/**
 @name Layout
 */

/**
 Lays out the subviews of the receiver with a provided visible rectangle
 @param rect The rectangle in which to lay out the subviews
 */
- (void)layoutSubviewsInRect:(CGRect)rect;


@end
