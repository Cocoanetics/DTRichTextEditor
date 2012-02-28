//
//  DTTextSelectionView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/7/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	DTTextSelectionStyleSelection = 0,
	DTTextSelectionStyleMarking
	
} DTTextSelectionStyle;

@class DTTextSelectionView;

@interface DTTextSelectionView : UIView
{
	UIImageView *_dragHandleLeft;
	UIImageView *_dragHandleRight;
	BOOL _showSelectionHandles;
	
	DTTextSelectionStyle _style;
	
	BOOL _dragHandlesVisible;
	BOOL _showsDragHandlesForSelection;
	
	NSArray *_selectionRectangles;
    NSMutableArray *_selectionRectangleViews;
    NSMutableSet *_reusableViews;
    
    UIView *_beginCaretView;
    UIView *_endCaretView;
	
	__unsafe_unretained UIView *_textView;
	
	UIColor *_cursorColor;
}

@property (nonatomic, retain) NSArray *selectionRectangles;
@property (nonatomic, unsafe_unretained) UIView *textView;

@property (nonatomic, assign) DTTextSelectionStyle style;
@property (nonatomic, assign) BOOL dragHandlesVisible;
@property (nonatomic, assign) BOOL showsDragHandlesForSelection;

@property (nonatomic, retain) UIImageView *dragHandleLeft;
@property (nonatomic, retain) UIImageView *dragHandleRight;

@property (nonatomic, retain) UIColor *cursorColor;


- (void)setSelectionRectangles:(NSArray *)selectionRectangles animated:(BOOL)animated;


- (id)initWithTextView:(UIView *)view;

- (void)setDragHandlesVisible:(BOOL)dragHandlesVisible animated:(BOOL)animated;

- (CGRect)beginCaretRect;
- (CGRect)endCaretRect;

- (void)layoutSubviewsInRect:(CGRect)rect;

- (CGRect)selectionEnvelope;

@end
