//
//  DTWebArchive.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTWebArchive.h"
#import "DTWebResource.h"


static NSString * const LegacyWebArchiveMainResourceKey = @"WebMainResource";
static NSString * const LegacyWebArchiveSubresourcesKey = @"WebSubresources";
static NSString * const LegacyWebArchiveSubframeArchivesKey =@"WebSubframeArchives";
static NSString * const LegacyWebArchiveResourceDataKey = @"WebResourceData";
static NSString * const LegacyWebArchiveResourceFrameNameKey = @"WebResourceFrameName";
static NSString * const LegacyWebArchiveResourceMIMETypeKey = @"WebResourceMIMEType";
static NSString * const LegacyWebArchiveResourceURLKey = @"WebResourceURL";
static NSString * const LegacyWebArchiveResourceTextEncodingNameKey = @"WebResourceTextEncodingName";
static NSString * const LegacyWebArchiveResourceResponseKey = @"WebResourceResponse";
static NSString * const LegacyWebArchiveResourceResponseVersionKey = @"WebResourceResponseVersion";

NSString * WebArchivePboardType = @"Apple Web Archive pasteboard type";


@interface DTWebArchive ()

@property (nonatomic, retain, readwrite) DTWebResource *mainResource;
@property (nonatomic, retain, readwrite) NSArray *subresources;
@property (nonatomic, retain, readwrite) NSArray *subframeArchives;

@end


/** Private interface to work with dictionaries */
@interface DTWebArchive (Dictionary)

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;
- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end


@implementation DTWebArchive

#pragma mark Initialization

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) 
	{
		NSDictionary *dict =[NSPropertyListSerialization propertyListFromData:data 
															 mutabilityOption:NSPropertyListImmutable 
																	   format:NULL 
															 errorDescription:nil];
        
        if (!dict)
        {
            return nil;
        }
        
		[self updateFromDictionary:dict];
    }
    
    return self;
}

- (id)initWithMainResource:(DTWebResource *)mainResource subresources:(NSArray *)subresources subframeArchives:(NSArray *)subframeArchives
{
	self = [super init];
	
	if (self)
	{
		self.mainResource = mainResource;
		self.subresources = subresources;
		self.subframeArchives = subframeArchives;
	}
	
	return self;
}

#pragma mark Getting Attributes

@synthesize mainResource = _mainResource;
@synthesize subresources = _subresources;
@synthesize subframeArchives = _subframeArchives;

- (NSData *)data
{
	// need to make a data representation first
	NSDictionary *dict = [self dictionaryRepresentation];
	
	return [NSPropertyListSerialization dataFromPropertyList:dict
													  format:NSPropertyListBinaryFormat_v1_0 
											errorDescription:NULL];
}

@end


@implementation DTWebArchive (Dictionary)

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if (self)
	{
		if (!dictionary)
		{
			return nil;
		}
		
		[self updateFromDictionary:dictionary];
	}
	
	return self;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
	self.mainResource = [[DTWebResource alloc] initWithDictionary:[dictionary objectForKey:LegacyWebArchiveMainResourceKey]];
	
	NSArray *subresources = [dictionary objectForKey:LegacyWebArchiveSubresourcesKey];
	if (subresources)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		// convert to DTWebResources
		for (NSDictionary *oneResourceDict in subresources)
		{
			DTWebResource *oneResource = [[DTWebResource alloc] initWithDictionary:oneResourceDict];
			[tmpArray addObject:oneResource];
		}
		
		self.subresources = tmpArray;
	}
	
	NSArray *subframeArchives = [dictionary objectForKey:LegacyWebArchiveSubframeArchivesKey];
	if (subframeArchives)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		// convert dictionaries to DTWebArchive objects
		for (NSDictionary *oneArchiveDict in subframeArchives)
		{
			DTWebArchive *oneArchive = [[DTWebArchive alloc] initWithDictionary:oneArchiveDict];
			[tmpArray addObject:oneArchive];
		}
		
		self.subframeArchives = tmpArray;
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	if (_mainResource)
	{
		[tmpDict setObject:[_mainResource dictionaryRepresentation] forKey:LegacyWebArchiveMainResourceKey];
	}
	
	if (_subresources)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (DTWebResource *oneResource in _subresources)
		{
			[tmpArray addObject:[oneResource dictionaryRepresentation]];
		}
		
		[tmpDict setObject:tmpArray forKey:LegacyWebArchiveSubresourcesKey];
	}
	
	if (_subframeArchives)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (DTWebArchive *oneArchive in _subframeArchives)
		{
			[tmpArray addObject:[oneArchive dictionaryRepresentation]];
		}
		
		[tmpDict setObject:tmpArray forKey:LegacyWebArchiveSubframeArchivesKey];
	}
	
	return tmpDict;
}

@end
