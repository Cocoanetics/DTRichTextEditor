//
//  DTTextPosition.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTTextPosition.h"


@implementation DTTextPosition


+ (DTTextPosition *)textPositionWithLocation:(NSInteger)location
{
	if (location<0)
	{
		return nil;
	}
	
	return [[[DTTextPosition alloc] initWithLocation:location] autorelease];
}

- (id)initWithLocation:(NSInteger)location
{
	self = [super init];
	
	if (self)
	{
		_location = location;
	}
	
	return self;
}

- (NSComparisonResult)compare:(id)object
{
	DTTextPosition *otherPosition = (DTTextPosition *)object;
	if (_location < otherPosition.location)
	{
		return NSOrderedAscending;
	}
	else if (_location > otherPosition.location)
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (BOOL)isEqual:(id)object;
{
	DTTextPosition *otherPosition = (DTTextPosition *)object;
	return [self compare:otherPosition]==NSOrderedSame;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ location=%d>", [self class], _location];
}

- (DTTextPosition *)textPositionWithOffset:(NSInteger)offset
{
	return [DTTextPosition textPositionWithLocation:_location + offset];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	DTTextPosition *newPosition = [[DTTextPosition allocWithZone:zone] init];
	newPosition.location = _location;
	
	return newPosition;
}


#pragma mark Properties

@synthesize location = _location;

@end
