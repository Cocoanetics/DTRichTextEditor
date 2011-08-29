//
//  DTTextSelectionView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTTextSelectionView.h"
#import <QuartzCore/QuartzCore.h>

@interface DTTextSelectionView ()

@property (nonatomic, retain) NSMutableArray *selectionRectangleViews;

- (UIColor *)currentSelectionColor;

@property (nonatomic, retain) UIView *beginCaretView;
@property (nonatomic, retain) UIView *endCaretView;

- (void)enqueueReusableView:(UIView *)view;
- (UIView *)dequeueReusableView;

@end



@implementation DTTextSelectionView

- (id)initWithTextView:(UIView *)view
{
    self = [super initWithFrame:view.bounds];
    if (self) 
	{
		self.textView = view;
	//	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeTopLeft;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
	[_cursorColor release];
	
	[_dragHandleLeft release];
	[_dragHandleRight release];
    
    [_selectionRectangles release];
    [_selectionRectangleViews release];
    
    [_beginCaretView release];
    [_endCaretView release];
    
    [_reusableViews release];
	
	[super dealloc];
}

//- (void)removeSubviewsOutsideRect:(CGRect)rect
//{
//	NSSet *allCustomViews = [NSSet setWithSet:customViews];
//	for (UIView *customView in self.subviews)
//	{
//		if (CGRectGetMinY(customView.frame)> CGRectGetMaxY(rect) || CGRectGetMaxY(customView.frame) < CGRectGetMinY(rect))
//		{
//		}
//	}
//}

- (NSArray *)selectionRectanglesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.selectionRectangles count]];
	
	BOOL earlyBreakPossible = NO;
	
	for (NSValue *oneValue in self.selectionRectangles)
	{
        CGRect oneRect = [oneValue CGRectValue];
        
        // CGRectIntersectsRect returns false if the frame has 0 width, which
        // lines that consist only of line-breaks have. Set the min-width
        // to one to work-around.
        oneRect.size.width = oneRect.size.width>1?oneRect.size.width:1;
		if (CGRectIntersectsRect(rect, oneRect))
		{
			[tmpArray addObject:oneValue];
			earlyBreakPossible = YES;
		}
		else
		{
			if (earlyBreakPossible)
			{
				break;
			}
		}
	}
	
	return tmpArray;
}

- (void)layoutSubviewsInRect:(CGRect)rect
{
    NSArray *selectionRectangles;
    
    if (CGRectIsInfinite(rect))
    {
        selectionRectangles = self.selectionRectangles;
    }
    else
    {
        selectionRectangles = [self selectionRectanglesVisibleInRect:rect];
    }
    
    NSArray *currentRectangleViews = [[self.selectionRectangleViews mutableCopy] autorelease];
    
    int i=0;
    
    for (; i<[selectionRectangles count]; i++)
    {
        CGRect rect = [[selectionRectangles objectAtIndex:i] CGRectValue];
        
        if (i < [currentRectangleViews count])
        {
            // view exists, resize 
            UIView *rectView = [currentRectangleViews objectAtIndex:i];
            
            if (!CGRectEqualToRect(rectView.frame, rect))
            {
                rectView.frame = rect;
            }
        }
        else
        {
            // add new
            UIView *rectView;
            
            rectView = [self dequeueReusableView];
            
            if (rectView)
            {
                rectView.frame = rect;
            }
            else
            {
                rectView = [[[UIView alloc] initWithFrame:rect] autorelease];
                rectView.userInteractionEnabled = NO;
            }
                
            rectView.backgroundColor = [self currentSelectionColor];
            
            [self.selectionRectangleViews insertObject:rectView atIndex:0];
            [self insertSubview:rectView atIndex:0];
         }
    }
    
    // remove views that are too many
    for (i = [selectionRectangles count]; i<[currentRectangleViews count]; i++)
    {
        UIView *rectView = [currentRectangleViews objectAtIndex:i];
        
        [self enqueueReusableView:rectView];
        
        [rectView removeFromSuperview];
        [self.selectionRectangleViews removeObject:rectView];
     }
    
    // position carets
    self.beginCaretView.frame = self.beginCaretRect;
    self.endCaretView.frame = self.endCaretRect;
    
    if (_dragHandlesVisible)
    {
        _beginCaretView.hidden = NO;
        _endCaretView.hidden = NO;
    }
    else
    {
        _beginCaretView.hidden = YES;
        _endCaretView.hidden = YES;
    }
}


// also called from adjustdraghandles
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //NSLog(@"layout");
    
    //[self layoutSubviewsInRect:CGRectInfinite];
}

#pragma mark Utilities
- (CGRect)beginCaretRect
{
	if (![_selectionRectangles count])
	{
		return CGRectNull;
	}
	
	CGRect rect = [[_selectionRectangles objectAtIndex:0] CGRectValue];
	rect.size.width = 3.0;
	return rect;
}

- (CGRect)endCaretRect
{
	if (![_selectionRectangles count])
	{
		return CGRectNull;
	}
	
	CGRect rect = [[_selectionRectangles lastObject] CGRectValue];
	rect.origin.x += rect.size.width;
	rect.size.width = 3.0;
	return rect;
}

- (CGRect)selectionEnvelope
{
	if (![_selectionRectangles count])
	{
		return CGRectNull;
	}
	
	CGRect unionRect = [[_selectionRectangles objectAtIndex:0] CGRectValue];
	
	// draw all these rectangles
	for (NSValue *value in _selectionRectangles)
	{
		CGRect rect = [value CGRectValue];
		
		unionRect = CGRectUnion(unionRect, rect);
	}
	
	return unionRect;
}

- (UIColor *)currentSelectionColor
{
    switch (_style) 
    {
        case DTTextSelectionStyleSelection:
            return [UIColor colorWithRed:0 green:0.338 blue:0.652 alpha:0.204];

        case DTTextSelectionStyleMarking:
            return [UIColor colorWithRed:0 green:0.652 blue:0.338 alpha:0.204];

        default:
            return [UIColor colorWithRed:0 green:0.652 blue:0.338 alpha:0.204];
    }
}

- (void)adjustDragHandles
{
	if (![_selectionRectangles count])
	{
		return;
	}
	
	CGRect firstRect = [self beginCaretRect];
	CGRect lastRect = [self endCaretRect];
	
	if (!CGRectIsNull(firstRect) && !CGRectIsNull(lastRect))
	{
		// might be called in animation block and we don't want handles to fly around
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		
		[self.superview addSubview:self.dragHandleLeft];
		_dragHandleLeft.center = CGPointMake(CGRectGetMidX(firstRect), firstRect.origin.y - 5.0);
		
		[self.superview addSubview:self.dragHandleRight];
		_dragHandleRight.center = CGPointMake(CGRectGetMidX(lastRect), CGRectGetMaxY(lastRect) + 9.0);
		
		[CATransaction commit];
	}
}


- (void)enqueueReusableView:(UIView *)view
{
    if (!_reusableViews)
    {
        _reusableViews = [[NSMutableSet alloc] init];
    }
    
    [_reusableViews addObject:view];
}

- (UIView *)dequeueReusableView
{
    UIView *view = [[_reusableViews anyObject] retain];
    
    if (view)
    {
        [_reusableViews removeObject:view];
    }
    
    return [view autorelease];
}

#pragma mark Drawing
//- (void)drawRect:(CGRect)rect
//{
//	if (![_selectionRectangles count])
//	{
//		// nothing to draw
//		return;
//	}
//	
//	
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	
//	// set color based on style
//	switch (_style) 
//	{
//		case DTTextSelectionStyleSelection:
//		{
//			CGContextSetRGBFillColor(ctx, 0, 0.338, 0.652, 0.204);
//			break;
//		}
//			
//		case DTTextSelectionStyleMarking:
//		{
//			CGContextSetRGBFillColor(ctx, 0, 0.652, 0.338, 0.204);
//			break;
//		}
//	}
//	
//	// draw all these rectangles
//	for (NSValue *value in _selectionRectangles)
//	{
//		CGRect rect = [value CGRectValue];
//		CGContextFillRect(ctx, rect);
//	}
//	
//	// draw selection carets at beginning and end of selection
//	if (_dragHandlesVisible)
//	{
//		CGContextSetFillColorWithColor(ctx, self.cursorColor.CGColor);
//		CGContextFillRect(ctx, [self beginCaretRect]);
//		
//		CGContextFillRect(ctx, [self endCaretRect]);
//	}
//}



#pragma mark Properties

- (void)setStyle:(DTTextSelectionStyle)style
{
	if (style != _style)
	{
		_style = style;
		
		//[self setNeedsDisplay];
        
        for (UIView *oneView in self.selectionRectangleViews)
        {
            oneView.backgroundColor = [self currentSelectionColor];
        }
	}
}

- (UIImageView *)dragHandleLeft
{
	if (!_dragHandleLeft)
	{
		_dragHandleLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		_dragHandleLeft.userInteractionEnabled = NO;
		_dragHandleLeft.image = [UIImage imageNamed:@"kb-drag-dot.png"];
		_dragHandleLeft.contentMode = UIViewContentModeCenter;
		_dragHandleLeft.alpha = 0;
	}
	
	return _dragHandleLeft;
}

- (UIImageView *)dragHandleRight
{
	if (!_dragHandleRight)
	{
		_dragHandleRight = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		_dragHandleRight.userInteractionEnabled = NO;
		_dragHandleRight.image = [UIImage imageNamed:@"kb-drag-dot.png"];
		_dragHandleRight.contentMode = UIViewContentModeCenter;
		_dragHandleRight.alpha = 0;
	}
	
	return _dragHandleRight;
}


- (void)setDragHandlesVisible:(BOOL)dragHandlesVisible animated:(BOOL)animated
{
	if (_dragHandlesVisible != dragHandlesVisible)
	{
		_dragHandlesVisible = dragHandlesVisible;
		
		if (_dragHandlesVisible)
		{
			[self adjustDragHandles];
				
				_dragHandleLeft.alpha = 1.0;
				_dragHandleRight.alpha = 1.0;
		}
		else
		{
			_dragHandleLeft.alpha = 0;
			_dragHandleRight.alpha = 0;
		}
	}
}

- (void)setDragHandlesVisible:(BOOL)dragHandlesVisible
{
	[self setDragHandlesVisible:dragHandlesVisible animated:NO];
}

- (void)setSelectionRectangles:(NSArray *)selectionRectangles
{
	if (_selectionRectangles != selectionRectangles)
	{
		[_selectionRectangles release];
		_selectionRectangles = [selectionRectangles retain];
		
		
		if (_selectionRectangles)
		{
			self.alpha = 1;
			//[self setNeedsDisplay];
            //[self setNeedsLayout];
            CGRect superRect = [self.superview bounds];
            [self layoutSubviewsInRect:superRect];
		}
		else
		{
			self.alpha = 0;
		}
        
        [self adjustDragHandles];

	}
}

- (UIColor *)cursorColor
{
	if (!_cursorColor)
	{
		_cursorColor = [[UIColor colorWithRed:66.07/255.0 green:107.0/255.0 blue:242.0/255.0 alpha:1.0] retain];
	}
	
	return _cursorColor;
}

- (void)setCursorColor:(UIColor *)cursorColor
{
	if (_cursorColor != cursorColor)
	{
		[_cursorColor release];
		_cursorColor = [_cursorColor retain];
        
       _beginCaretView.backgroundColor = _cursorColor;
        _endCaretView.backgroundColor = _cursorColor;
		
		[self setNeedsDisplay];
	}
}

- (NSMutableArray *)selectionRectangleViews
{
    if (!_selectionRectangleViews)
    {
        _selectionRectangleViews = [[NSMutableArray alloc] init];
    }
    
    return _selectionRectangleViews;
}

- (UIView *)beginCaretView
{
    if (!_beginCaretView)
    {
        _beginCaretView = [[UIView alloc] initWithFrame:[self beginCaretRect]];
        _beginCaretView.backgroundColor = self.cursorColor;
        _beginCaretView.userInteractionEnabled = NO;
        
        [self addSubview:_beginCaretView];
    }
    
    return _beginCaretView;
}

- (UIView *)endCaretView
{
    if (!_endCaretView)
    {
        _endCaretView = [[UIView alloc] initWithFrame:[self endCaretRect]];
        _endCaretView.backgroundColor = self.cursorColor;
        _endCaretView.userInteractionEnabled = NO;
        
        [self addSubview:_endCaretView];
    }
    
    return _endCaretView;
}


@synthesize selectionRectangles = _selectionRectangles;
@synthesize selectionRectangleViews = _selectionRectangleViews;
@synthesize beginCaretView = _beginCaretView;
@synthesize endCaretView = _endCaretView;
@synthesize style = _style;
@synthesize dragHandlesVisible = _dragHandlesVisible;
@synthesize dragHandleLeft = _dragHandleLeft;
@synthesize dragHandleRight = _dragHandleRight;
@synthesize textView = _textView;

@end
