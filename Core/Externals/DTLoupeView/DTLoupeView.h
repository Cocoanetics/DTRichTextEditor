//
//  DTLoupeView.h
//  DTLoupe
//
//  Created by Michael Kaye on 21/06/2011.
//  Copyright 2011 sendmetospace.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
    DTLoupeStyleCircle = 0,
    DTLoupeStyleRectangle,
    DTLoupeStyleRectangleWithArrow,
} DTLoupeStyle;

extern NSString * const DTLoupeDidHide;

@interface DTLoupeView : UIView 
{
    DTLoupeStyle    _style;                     // Type of Loupe; None, Circle, Rectangle, Rectangle With Arrow

    CGPoint         _touchPoint;                // The point at which to display (in our target view's bounds coordinates)
	CGPoint _touchPointOffset;
    CGFloat         _magnification;             // How much to magnify the view
    CGPoint         _magnifiedImageOffset;          // Offset of vertical position of magnified image from centre of Loupe NB Touchpoint is normally centered in Loupe

    UIView          *_targetView;               // View to Magnify
	UIView			*_rootView;					// the actually used view, because this has orientation changes applied
    
	// A Loupe/Magnifier is based on 3 images. Background, Mask & Main
    UIImage         *_loupeFrameImage;           
    UIImage         *_loupeFrameBackgroundImage;
    UIImage         *_loupeFrameMaskImage;
    
	BOOL _seeThroughMode; // look-through-mode, used while scrolling
	
    BOOL _drawDebugCrossHairs;       // Draws cross hairs for debugging
}

@property(nonatomic,assign) CGPoint touchPoint;
@property(nonatomic, assign) CGPoint touchPointOffset;

@property(nonatomic,assign) DTLoupeStyle style;
@property(nonatomic,assign) CGFloat magnification;
@property(nonatomic,assign) CGPoint magnifiedImageOffset;

@property(nonatomic,assign) UIView *targetView;

@property(nonatomic,assign) BOOL drawDebugCrossHairs;
@property(nonatomic,assign) BOOL seeThroughMode;

- (id)initWithStyle:(DTLoupeStyle)style targetView:(UIView *)targetView;
- (void)presentLoupeFromLocation:(CGPoint)location;
- (void)dismissLoupeTowardsLocation:(CGPoint)location;

- (BOOL)isShowing;

@end
