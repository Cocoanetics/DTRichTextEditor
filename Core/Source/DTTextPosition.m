//
//  DTTextPosition.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTTextPosition.h"

@interface DTTextPosition () // private

@property (nonatomic, assign) NSUInteger location;

@end


@implementation DTTextPosition
{
	NSUInteger _location;
}

+ (DTTextPosition *)textPositionWithLocation:(NSUInteger)location
{
	return [[DTTextPosition alloc] initWithLocation:location];
}

- (id)initWithLocation:(NSUInteger)location
{
	self = [super init];
	
	if (self)
	{
		_location = location;
	}
	
	return self;
}

- (NSComparisonResult)compare:(UITextPosition *)otherPosition
{
	if (_location < [(DTTextPosition *)otherPosition location])
	{
		return NSOrderedAscending;
	}
	else if (_location > [(DTTextPosition *)otherPosition location])
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (BOOL)isEqual:(DTTextPosition *)otherPosition;
{
	return [self compare:otherPosition]==NSOrderedSame;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ location=%lu>", [self class], (unsigned long)_location];
}

- (DTTextPosition *)textPositionWithOffset:(NSInteger)offset
{
	return [DTTextPosition textPositionWithLocation:_location + offset];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	DTTextPosition *newPosition = [[DTTextPosition allocWithZone:zone] init];
	newPosition.location = self.location;
	
	return newPosition;
}


#pragma mark Properties

@synthesize location = _location;

@end
