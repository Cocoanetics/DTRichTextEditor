//
//  DTSelectionGestureRecognizer.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTSelectionGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>


#define SHORT_TAP_DURATION 0.25
#define MAX_ALLOWABLE_MOVEMENT 10.0


@interface DTSelectionGestureRecognizer ()

@property (nonatomic, assign) DTSelectionState selectionState;

@end


@implementation DTSelectionGestureRecognizer

- (void)reset
{
	NSLog(@"reset");
	_didDrag = NO;
	_selectionState = DTSelectionStateUnknown;
}


- (void)handleLongPress
{
	NSLog(@"detected long press");

	self.state = UIGestureRecognizerStateBegan;
	self.selectionState = DTSelectionStateLongPress;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (self.state != UIGestureRecognizerStatePossible)
	{
        return;
	}
	
	firstTouchTimestamp = [event timestamp];
	latestTouchTimestamp = firstTouchTimestamp;
	
	firstTouchPoint = [self locationInView:self.view];

	NSLog(@"began");	

	
	
	// fail if touched with more than 1 finger
    if ([touches count] != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
	
	[self performSelector:@selector(handleLongPress) withObject:nil afterDelay:SHORT_TAP_DURATION];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	// cancel long press
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

//	if (self.state != UIGestureRecognizerStatePossible)
//	{
//		NSLog(@"hier");
//        return;
//	}
//	NSLog(@"hier2");
	
	latestTouchTimestamp = [event timestamp];
	NSLog(@"moved %d, begin %d changed %d, failed %d, cancelled %d", self.state, UIGestureRecognizerStateBegan, UIGestureRecognizerStateChanged, UIGestureRecognizerStateFailed, UIGestureRecognizerStateCancelled);
	
	CGPoint touchPoint = [self locationInView:self.view];
	CGFloat dx = touchPoint.x - firstTouchPoint.x;
	CGFloat dy = touchPoint.y - firstTouchPoint.y;
	CGFloat distance = sqrtf(dx*dx + dy*dy);
	
	NSLog(@"distance: %f", distance);
	
	if (!_didDrag && !(self.selectionState == DTSelectionStateLongPress) && distance > MAX_ALLOWABLE_MOVEMENT)
	{
		_didDrag = YES;
		self.selectionState = DTSelectionStateDragging;
		self.state = UIGestureRecognizerStateFailed;
		
		
		NSLog(@"moved too much");
		
		
		return;
	}
	
	if (self.state == UIGestureRecognizerStateBegan)
	{
		self.state = UIGestureRecognizerStateChanged;
	}
	else if (self.state == UIGestureRecognizerStatePossible)
	{
		self.state = UIGestureRecognizerStateBegan;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	
	latestTouchTimestamp = [event timestamp];
	NSLog(@"ended");
	
	NSTimeInterval timeSinceInitialTouch = (latestTouchTimestamp - firstTouchTimestamp);

	// cancel long press
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	if (_selectionState == DTSelectionStateUnknown)
	{
		if (timeSinceInitialTouch <= SHORT_TAP_DURATION)
		{
		
		self.selectionState = DTSelectionStateTap;
		self.state = UIGestureRecognizerStateEnded;
		
		NSLog(@"detected tap");
		
		return;
	}
	}
	
	if (self.state == UIGestureRecognizerStateChanged || self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStatePossible)
	{
		self.state = UIGestureRecognizerStateEnded;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];

	
	latestTouchTimestamp = [event timestamp];
	NSLog(@"cancelled");
	self.state = UIGestureRecognizerStateCancelled;

	// cancel long press
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}


- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	NSLog(@"can prevent: %@", [preventedGestureRecognizer class]);
	
//	if (_selectionState == DTSelectionStateLongPress)
//	{
//		return YES;
//	}
	
	return YES;
}
//
//
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	NSLog(@"can be prevented by: %@", [preventingGestureRecognizer class]);
	
	//self.state = UIGestureRecognizerStateFailed;
	
	return YES;
	
}

- (void)setState:(UIGestureRecognizerState)state
{
	NSLog(@"state: %d", state);
	[super setState:state];
}

@synthesize selectionState;

@end
