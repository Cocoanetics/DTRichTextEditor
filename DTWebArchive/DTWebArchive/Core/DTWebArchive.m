//
//  DTWebArchive.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTWebArchive.h"
#import "DTWebResource.h"
#import "NSDictionary+Data.h"


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
@property (nonatomic, retain, readwrite) NSData *data;

- (void)updateFromDictionary:(NSDictionary *)dictionary;

@end

@implementation DTWebArchive

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) 
	{
		self.data = data;
		
		//NSKeyedUnarchiver *a = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		
		//id bla = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		NSDictionary *dict = [NSDictionary dictionaryWithData:data];
		[self updateFromDictionary:dict];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if (self)
	{
		if (!dictionary)
		{
			[self autorelease];
			return nil;
		}
		
		[self updateFromDictionary:dictionary];
	}
	
	return self;
}

- (void)dealloc	
{
	[_mainResource release];
	[_subresources release];
	[_subframeArchives release];
	[_data release];
	
	[super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary
{
	self.mainResource = [DTWebResource webResourceWithDictionary:[dictionary objectForKey:LegacyWebArchiveMainResourceKey]];
	
	
	NSArray *subresources = [dictionary objectForKey:LegacyWebArchiveSubresourcesKey];
	if (subresources)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		// convert to DTWebResources
		for (NSDictionary *oneResourceDict in subresources)
		{
			DTWebResource *oneResource = [[DTWebResource alloc] initWithDictionary:oneResourceDict];
			[tmpArray addObject:oneResource];
			[oneResource release];		}
		
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
			[oneArchive release];
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
	
	if (_data)
	{
		[tmpDict setObject:_data forKey:LegacyWebArchiveResourceDataKey];
	}
	
	return tmpDict;
}

#pragma mark Properties

@synthesize mainResource = _mainResource;
@synthesize subresources = _subresources;
@synthesize subframeArchives = _subframeArchives;
@synthesize data = _data;

@end
