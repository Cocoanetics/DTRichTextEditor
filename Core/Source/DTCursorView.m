//
//  DTCursorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTCursorView.h"


NSString * const DTCursorViewDidBlink = @"DTCursorViewDidBlink";

@implementation DTCursorView
{
	NSTimer *blinkingTimer;
	DTCursorState _state;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		if ([self respondsToSelector:@selector(tintColor)])
		{
			self.backgroundColor = self.tintColor;
		}
		else
		{
			self.backgroundColor = [UIColor colorWithRed:66.07/255.0 green:107.0/255.0 blue:242.0/255.0 alpha:1.0];
		}
	}
	return self;
}

- (void)dealloc
{
	[blinkingTimer invalidate], blinkingTimer = nil;
}

- (void)setTimerForNextBlink
{
	[blinkingTimer invalidate], blinkingTimer = nil;
	
	if (self.hidden)
	{
		blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(blink:) userInfo:nil repeats:NO];
	}
	else 
	{
		blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(blink:) userInfo:nil repeats:NO];
	}
}

// start timer when becoming visible, stop when off a window
- (void)willMoveToWindow:(UIWindow *)newWindow
{
	if (newWindow)
	{
		// blink after a while again
		[self setTimerForNextBlink];
	}
	else 
	{
		[blinkingTimer invalidate], blinkingTimer = nil;
	}
}

- (void)setFrame:(CGRect)newFrame
{
	[super setFrame:newFrame];
	
	// frame changing keeps cursor visible
	[blinkingTimer invalidate], blinkingTimer = nil;
	self.hidden = NO;

	// blink after a while again
	[self setTimerForNextBlink];
}

- (void)blink:(NSTimer *)timer
{
	if (_state == DTCursorStateStatic)
	{
		return;
	}
	
	self.hidden = !self.hidden;
	
	[self setTimerForNextBlink];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DTCursorViewDidBlink object:self];
}

- (void)tintColorDidChange
{
	self.backgroundColor = self.tintColor;
}

#pragma mark Properties

- (void)setState:(DTCursorState)state
{
	_state = state;
	
	switch (state) 
	{
		case DTCursorStateBlinking:
		{
			[self setTimerForNextBlink];
			
			break;
		}
			
		case DTCursorStateStatic:
		{
			[blinkingTimer invalidate], blinkingTimer = nil;
			
			self.hidden = NO;
			
			break;
		}
	}
}

@synthesize state = _state;

@end
