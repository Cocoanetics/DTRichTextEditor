//
//  DTTextSelectionRect.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 9/11/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTTextSelectionRect.h"

@implementation DTTextSelectionRect

+ (DTTextSelectionRect *)textSelectionRectWithRect:(CGRect)rect
{
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
