//
//  DTTextSelectionView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTTextSelectionView.h"

@interface DTTextSelectionView ()



@end



@implementation DTTextSelectionView

- (id)initWithTextView:(UIView *)view
{
    self = [super initWithFrame:view.bounds];
    if (self) 
	{
		self.textView = view;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
	[_textView release];
	[_cursorColor release];
	
	[_dragHandleLeft release];
	[_dragHandleRight release];
	
	[super dealloc];
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
		
		[self.superview addSubview:self.dragHandleLeft];
		_dragHandleLeft.center = CGPointMake(CGRectGetMidX(firstRect), firstRect.origin.y - 5.0);
		
		[self.superview addSubview:self.dragHandleRight];
		_dragHandleRight.center = CGPointMake(CGRectGetMidX(lastRect), CGRectGetMaxY(lastRect) + 9.0);
	}
}

#pragma mark Drawing
- (void)drawRect:(CGRect)rect
{
	if (![_selectionRectangles count])
	{
		// nothing to draw
		return;
	}
	
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// set color based on style
	switch (_style) 
	{
		case DTTextSelectionStyleSelection:
		{
			CGContextSetRGBFillColor(ctx, 0, 0.338, 0.652, 0.204);
			break;
		}
			
		case DTTextSelectionStyleMarking:
		{
			CGContextSetRGBFillColor(ctx, 0, 0.652, 0.338, 0.204);
			break;
		}
	}
	
	// draw all these rectangles
	for (NSValue *value in _selectionRectangles)
	{
		CGRect rect = [value CGRectValue];
		CGContextFillRect(ctx, rect);
	}
	
	// draw selection carets at beginning and end of selection
	if (_dragHandlesVisible)
	{
		CGContextSetFillColorWithColor(ctx, self.cursorColor.CGColor);
		CGContextFillRect(ctx, [self beginCaretRect]);
		
		CGContextFillRect(ctx, [self endCaretRect]);
	}
}



#pragma mark Properties

- (void)setStyle:(DTTextSelectionStyle)style
{
	if (style != _style)
	{
		_style = style;
		
		[self setNeedsDisplay];
	}
}

- (UIImageView *)dragHandleLeft
{
	if (!_dragHandleLeft)
	{
		_dragHandleLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		_dragHandleLeft.userInteractionEnabled = YES;
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
		_dragHandleRight.userInteractionEnabled = YES;
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
		
		[self adjustDragHandles];
		
		[self setNeedsDisplay];
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
		cursorColor = [_cursorColor retain];
		
		[self setNeedsDisplay];
	}
}

@synthesize selectionRectangles = _selectionRectangles;
@synthesize style = _style;
@synthesize dragHandlesVisible = _dragHandlesVisible;
@synthesize dragHandleLeft = _dragHandleLeft;
@synthesize dragHandleRight = _dragHandleRight;
@synthesize textView = _textView;

@end
