//
//  DTCursorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCursorView.h"


@implementation DTCursorView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor colorWithRed:66.07/255.0 green:107.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
    return self;
}

- (void)dealloc 
{
	[blinkingTimer invalidate], blinkingTimer = nil;
    [super dealloc];
}


// start timer when becoming visible, stop when off a window
- (void)willMoveToWindow:(UIWindow *)newWindow
{
	if (newWindow)
	{
		// now visible
		if (!blinkingTimer)
		{
		}
	}
	else 
	{
		//[blinkingTimer invalidate], blinkingTimer = nil;
	}
}

- (void)setFrame:(CGRect)newFrame
{
	if (newFrame.size.width==0)
	{
		NSLog(@"???");
	}
	
	// frame changing keeps cursor visible
	[blinkingTimer invalidate], blinkingTimer = nil;
	self.hidden = NO;
	
	[super setFrame:newFrame];
	
	blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(blink:) userInfo:nil repeats:NO];
}

- (void)blink:(NSTimer *)timer
{
	self.hidden = !self.hidden;
	
//	NSLog(@"%@", NSStringFromCGRect(self.frame));
	
	if (self.hidden)
	{
		blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(blink:) userInfo:nil repeats:NO];
	}
	else 
	{
		blinkingTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(blink:) userInfo:nil repeats:NO];
	}

}


@end
