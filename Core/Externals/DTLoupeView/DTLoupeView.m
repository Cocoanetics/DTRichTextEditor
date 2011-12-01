//
//  DTLoupeView.m
//  DTLoupe
//
//  Created by Michael Kaye on 21/06/2011.
//  Copyright 2011 sendmetospace.co.uk. All rights reserved.
//

#import "DTLoupeView.h"
#import "UIView+DT.h"
#import <QuartzCore/QuartzCore.h>

#define DTLoupeDefaultMagnification         1.20     // Match Apple's Magnification
#define DTLoupeAnimationDuration			0.15     // Match Apple's Duration

CGAffineTransform CGAffineTransformAndScaleMake(CGFloat sx, CGFloat sy, CGFloat tx, CGFloat ty);

NSString * const DTLoupeDidHide = @"DTLoupeDidHide";

@interface DTLoupeView ()

+ (CGSize)sizeForLoupeStyle:(DTLoupeStyle)style;
+ (CGPoint)offsetFromCenterForLoupeStyle:(DTLoupeStyle)style;

@property (nonatomic, retain) UIImage * loupeFrameImage; 
@property (nonatomic, retain) UIImage * loupeFrameBackgroundImage;
@property (nonatomic, retain) UIImage * loupeFrameMaskImage;

@end

@implementation DTLoupeView

- (id)initWithStyle:(DTLoupeStyle)style targetView:(UIView *)targetView
{
	CGSize size = [DTLoupeView sizeForLoupeStyle:style];
	CGRect frame = CGRectMake(0, 0, size.width, size.height);
	
	self = [super initWithFrame:frame];
	if (self)
	{
		self.contentMode = UIViewContentModeCenter;
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		
		self.style = style;
		self.targetView = targetView;
		
		_magnification = DTLoupeDefaultMagnification;
		
		// because target view might be smaller than screen and clipping
		[[_targetView rootView] addSubview:self];
	}
	
	return self;
}

- (void)dealloc
{
	[_loupeFrameImage release];
	[_loupeFrameBackgroundImage release];
	[_loupeFrameMaskImage release];
	
    [super dealloc];
}

#pragma mark Utilities

// there is a difference between concatenating and scaling an existing transform
CGAffineTransform CGAffineTransformAndScaleMake(CGFloat sx, CGFloat sy, CGFloat tx, CGFloat ty)
{
	CGAffineTransform transform = CGAffineTransformMakeTranslation(tx, ty); 
	return CGAffineTransformScale(transform, sx, sy);	
}

// round up image sizes so that setting center does not cause non-integer origin of view
+ (CGSize)sizeForLoupeStyle:(DTLoupeStyle)style;
{
	switch (style) 
	{
		case DTLoupeStyleCircle:
			return CGSizeMake(128.0, 128.0);
			
		case DTLoupeStyleRectangle:
			return CGSizeMake(142.0, 56.0);
			
		case DTLoupeStyleRectangleWithArrow:
			return CGSizeMake(145.0, 59.0);
			
		default:
			return CGSizeZero;
	}
}

+ (CGPoint)offsetFromCenterForLoupeStyle:(DTLoupeStyle)style
{
	switch (style) 
	{
		case DTLoupeStyleCircle:
			return CGPointMake(0, -60.0);
			
		case DTLoupeStyleRectangle:
			return CGPointMake(0, -30.0);
			
		case DTLoupeStyleRectangleWithArrow:
			return CGPointMake(0, -30.0);
			
		default:
			return CGPointZero;
	}
}

+ (CGPoint)magnifiedImageOffsetForStyle:(DTLoupeStyle)style
{
	switch (style) 
	{
		case DTLoupeStyleCircle:
		{
			return CGPointMake(0, -4.0);
		}	
		case DTLoupeStyleRectangle:
		{
			return CGPointMake(0, -18.0);
		}
			
		case DTLoupeStyleRectangleWithArrow:
		{
			return CGPointMake(0, -18.0);
		}
			
		default:
			return CGPointZero;
	}
}

- (void)setImagesForStyle:(DTLoupeStyle)style
{
	switch (style) 
	{
		case DTLoupeStyleCircle:
		{
			self.loupeFrameBackgroundImage = [UIImage imageNamed:@"kb-loupe-lo.png"];
			self.loupeFrameMaskImage = [UIImage imageNamed:@"kb-loupe-mask.png"];
			self.loupeFrameImage = [UIImage imageNamed:@"kb-loupe-hi.png"];
			
			break;
		}	
		case DTLoupeStyleRectangle:
		{
			self.loupeFrameBackgroundImage = [UIImage imageNamed:@"kb-magnifier-ranged-lo-stemless.png"];
			self.loupeFrameMaskImage = [UIImage imageNamed:@"kb-magnifier-ranged-mask.png"];
			self.loupeFrameImage = [UIImage imageNamed:@"kb-magnifier-ranged-hi.png"];
			
			break;
		}
			
		case DTLoupeStyleRectangleWithArrow:
		{
			self.loupeFrameBackgroundImage = [UIImage imageNamed:@"kb-magnifier-ranged-lo.png"];
			self.loupeFrameMaskImage = [UIImage imageNamed:@"kb-magnifier-ranged-mask.png"];
			self.loupeFrameImage = [UIImage imageNamed:@"kb-magnifier-ranged-hi.png"];
			
			break;
		}
	}	
}

#pragma mark Interactivity
- (void)setTouchPoint:(CGPoint)touchPoint
{
	// Set touchPoint as user moves around screen
	_touchPoint = touchPoint;
	
	CGPoint convertedLocation = [_targetView convertPoint:_touchPoint toView:self.superview];

	CGPoint newCenter = convertedLocation;
	CGPoint offsetFromTouchPoint = [DTLoupeView offsetFromCenterForLoupeStyle:_style];
	
	newCenter.x += offsetFromTouchPoint.x;
	newCenter.y += offsetFromTouchPoint.y;
	
	// We do it here so that the centre of displayed "magnified image" 
    // captured in drawRect doesn't need to be adjusted
	
    self.center = newCenter;
	
	// Update our magnified image to reflect the new touchpoint
	[self setNeedsDisplay];
}

- (void)presentLoupeFromLocation:(CGPoint)location
{
	// circular loupe does not fade
	self.alpha = (_style == DTLoupeStyleCircle)?1.0:0.0;
	
	// calculate transform
	CGPoint convertedLocation = [_targetView convertPoint:location toView:self.superview];
	CGPoint offset = CGPointMake(convertedLocation.x - self.center.x, convertedLocation.y - self.center.y);
	self.transform = CGAffineTransformAndScaleMake(0.25, 0.25, offset.x, offset.y);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:DTLoupeAnimationDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	self.alpha = 1.0;
	self.transform = CGAffineTransformIdentity;

	[UIView commitAnimations];
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	// hide it completely
	self.alpha = 0;
	
	// keep it in view hierarchy
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DTLoupeDidHide object:self];
}

- (void)dismissLoupeTowardsLocation:(CGPoint)location
{
	// calculate transform
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:DTLoupeAnimationDuration];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
	
	// circular loupe does not fade
	self.alpha = (_style == DTLoupeStyleCircle)?1.0:0.0;

	// calculate transform
	CGPoint convertedLocation = [_targetView convertPoint:location toView:self.superview];
	CGPoint offset = CGPointMake(convertedLocation.x - self.center.x, convertedLocation.y - self.center.y);
	self.transform = CGAffineTransformAndScaleMake(0.05, 0.05, offset.x, offset.y);
	
	[UIView commitAnimations];
}

- (BOOL)isShowing
{
	return (self.superview != nil && self.alpha>0);
}

// Draw our Loupe
- (void)drawRect:(CGRect)rect;
{
    CGContextRef ctx = UIGraphicsGetCurrentContext(); 
	
	//CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
	
    // **** Draw our Loupe's Background Image ****
    [_loupeFrameBackgroundImage drawAtPoint:CGPointZero];

	CGContextSaveGState(ctx);   
	
	// clip to inner area of loupe
    CGContextClipToMask(ctx, rect, _loupeFrameMaskImage.CGImage);
	
	if (_seeThroughMode)
	{
		CGContextClearRect(ctx, rect);
		CGContextSetGrayFillColor(ctx, 1.0, 0.5);
		CGContextFillRect(ctx, rect);
	}
	else
	{
		// **** Draw our Target View Magnified and correctly positioned ****
		// move touchpoint by offset
		CGPoint offsetTouchPoint = _touchPoint;
		offsetTouchPoint.x += _touchPointOffset.x;
		offsetTouchPoint.y += _touchPointOffset.y;
		
		CGPoint convertedLocation = [_targetView convertPoint:offsetTouchPoint toView:_rootView];
		
		
		// Translate Right & Down, Scale and then shift back to touchPoint
		CGContextTranslateCTM(ctx, self.frame.size.width * 0.5 + _magnifiedImageOffset.x,(self.frame.size.height * 0.5) + _magnifiedImageOffset.y);
		CGContextScaleCTM(ctx, _magnification, _magnification);
		
		//CGContextConcatCTM(ctx, CGAffineTransformInvert(_rotationTransform));
		CGContextTranslateCTM(ctx,-convertedLocation.x, -convertedLocation.y);

		// briefly hide self so that contents does not show up in screenshot
		self.hidden = YES;
		[_rootView.layer renderInContext:ctx];
		self.hidden = NO;
	}

	CGContextRestoreGState(ctx);

    // **** Draw our Loupe's Main Image ****
    [_loupeFrameImage drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:1.0];
	
    // Draw Cross Hairs
    if (_drawDebugCrossHairs) 
	{
		[[UIColor redColor] setStroke];
        CGContextStrokeRect(ctx, rect);
        CGContextMoveToPoint(ctx, 0, rect.size.height/2.0f);
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height/2.0f);
        CGContextStrokePath(ctx);
        CGContextMoveToPoint(ctx, rect.size.width/2.0f, 0);
        CGContextAddLineToPoint(ctx, rect.size.width/2.0f, rect.size.height);
        CGContextStrokePath(ctx);
    }
}

#pragma mark Properties
- (void)setTargetView:(UIView *)targetView
{
	if (targetView != _targetView)
	{
		_targetView = targetView;
		_rootView = [_targetView rootView];
	}
}

- (void)setStyle:(DTLoupeStyle)style
{
	_style = style;
	
	[self setImagesForStyle:style];
	
	CGSize size = [DTLoupeView sizeForLoupeStyle:style];
	CGRect bounds = CGRectMake(0, 0, size.width, size.height);
	self.bounds = bounds;
	
	// Different loupes have a different vertical offset for the magnified image (otherwise the touchpoint = equals the centre of maginified image)
	// Circular Loupe is set -4.0f for example
	// With Rectangular Loupe the offset depends on whether clicking the Top or Bottom Text selection Thumb!
	_magnifiedImageOffset = [DTLoupeView magnifiedImageOffsetForStyle:style];
	
	_touchPointOffset = CGPointZero;
	
	[self setNeedsDisplay];
}

- (void)setSeeThroughMode:(BOOL)seeThroughMode
{
	if (_seeThroughMode != seeThroughMode)
	{
		_seeThroughMode = seeThroughMode;
		[self setNeedsDisplay];
	}
}

- (void)setMagnification:(CGFloat)magnification
{
	if (_magnification != magnification)
	{
		_magnification = magnification;
		[self setNeedsDisplay];
	}
}

@synthesize loupeFrameImage = _loupeFrameImage;
@synthesize loupeFrameBackgroundImage = _loupeFrameBackgroundImage;
@synthesize loupeFrameMaskImage = _loupeFrameMaskImage;

@synthesize touchPoint = _touchPoint;
@synthesize touchPointOffset = _touchPointOffset;
@synthesize style = _style;
@synthesize magnification = _magnification;
@synthesize targetView = _targetView;
@synthesize magnifiedImageOffset = _magnifiedImageOffset;

@synthesize seeThroughMode = _seeThroughMode;
@synthesize drawDebugCrossHairs = _drawDebugCrossHairs;

@end
