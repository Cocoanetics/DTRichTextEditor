//
//  DTTextSelectionRect.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 9/11/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTTextSelectionRect.h"

// on iOS 6 there is a new UITextSelectionRect class we want to be a subclass of
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1

@implementation DTTextSelectionRectDerived
{
	CGRect _rect;
	UITextWritingDirection _writingDirection;
}

- (id)initWithRect:(CGRect)rect
{
	self = [super init];
	
	if (self)
	{
		_rect = rect;
		_writingDirection = UITextWritingDirectionLeftToRight;
	}
	
	return self;
}

#pragma mark Properties

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

@end

#endif


@implementation DTTextSelectionRect
{
	CGRect _rect;
	UITextWritingDirection _writingDirection;
}

+ (id <DTTextSelectionRect>)textSelectionRectWithRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
	if ([UITextSelectionRect class])
	{
		return [[DTTextSelectionRectDerived alloc] initWithRect:rect];
	}
#endif
	
	return [[DTTextSelectionRect alloc] initWithRect:rect];
}

- (id)initWithRect:(CGRect)rect
{
	self = [super init];
	
	if (self)
	{
		_rect = rect;
		_writingDirection = UITextWritingDirectionLeftToRight;
	}
	
	return self;
}

#pragma mark Properties

@synthesize rect = _rect;
@synthesize writingDirection = _writingDirection;
@synthesize containsStart = _containsStart;
@synthesize containsEnd = _containsEnd;
@synthesize isVertical = _isVertical;

@end
