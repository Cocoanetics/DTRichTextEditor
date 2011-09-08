//
//  NSDictionary+Data.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSDictionary+Data.h"





@implementation NSDictionary (Data)

+ (NSDictionary *)dictionaryWithData:(NSData *)data
{
	return [[[NSDictionary alloc] initWithData:data] autorelease];
}

- (id)initWithData:(NSData *)data
{
	// no super init
	[self autorelease];
	
	// deserialize it
	id obj = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable 
														format:NULL 
											  errorDescription:nil];

	// is autoreleased so we retain it
	[obj retain];
	
	return obj;
}

- (NSData *)dataRepresentation
{
	return [NSPropertyListSerialization dataFromPropertyList:self format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
}


@end
