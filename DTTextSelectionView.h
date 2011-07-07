//
//  DTTextSelectionView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	DTTextSelectionStyleSelection = 0,
	DTTextSelectionStyleMarking
	
} DTTextSelectionStyle;


@interface DTTextSelectionView : UIView
{
	UIImageView *_dragHandleLeft;
	UIImageView *_dragHandleRight;
	BOOL _showSelectionHandles;
	
	DTTextSelectionStyle _style;
	
	BOOL _dragHandlesVisible;
	
	NSArray *_selectionRectangles;
	
	UIView *_textView;
	
	UIColor *_cursorColor;
}

@property (nonatomic, retain) NSArray *selectionRectangles;
@property (nonatomic, assign) UIView *textView;

@property (nonatomic, assign) DTTextSelectionStyle style;
@property (nonatomic, assign) BOOL dragHandlesVisible;

@property (nonatomic, retain) UIImageView *dragHandleLeft;
@property (nonatomic, retain) UIImageView *dragHandleRight;

@property (nonatomic, retain) UIColor *cursorColor;



- (id)initWithTextView:(UIView *)view;

- (void)setDragHandlesVisible:(BOOL)dragHandlesVisible animated:(BOOL)animated;

- (CGRect)beginCaretRect;
- (CGRect)endCaretRect;

@end
