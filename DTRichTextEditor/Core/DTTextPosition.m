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
	if (self = [super init])
	{
		_location = location;
	}
	
	return self;
}

- (NSComparisonResult)compare:(DTTextPosition *)other
{
	if (_location < other.location)
	{
		return NSOrderedAscending;
	}
	else if (_location > other.location)
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

- (BOOL)isEqual:(DTTextPosition *)aPosition
{
	return [self compare:aPosition]==NSOrderedSame;
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ location=%d>", [self class], _location];
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
