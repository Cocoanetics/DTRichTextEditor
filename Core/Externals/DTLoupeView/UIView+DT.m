//
//  UIView+DT.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "UIView+DT.h"

@implementation UIView (DT)

- (UIView *)rootView
{
	UIView *view = self;
	
	while (view.superview != view.window)
	{
		view = view.superview;
	}
	
	return view;
}

- (CGAffineTransform)transformRelativeToWindow
{
	// walk up superviews until we find the window
	
	UIView *view = self;
	NSMutableArray *stack = [NSMutableArray array];
	
	while (view.superview != view.window)
	{
		[stack addObject:view];
		view = view.superview;
	}
	
	// this is the first subview of window
	CGAffineTransform transform = view.transform;
	
	// walk back down to view and sum transforms
	while (view != self)
	{
		view = [stack lastObject];
		transform = CGAffineTransformConcat(transform, view.transform);
		[stack removeLastObject];
	}

	// return compound
	return transform;
}

@end
