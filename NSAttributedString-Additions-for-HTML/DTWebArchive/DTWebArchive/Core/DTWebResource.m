//
//  DTWebResource.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTWebResource.h"

static NSString * const WebResourceDataKey = @"WebResourceData";
static NSString * const WebResourceFrameNameKey = @"WebResourceFrameName";
static NSString * const WebResourceMIMETypeKey = @"WebResourceMIMEType";
static NSString * const WebResourceURLKey = @"WebResourceURL";
static NSString * const WebResourceTextEncodingNameKey =  @"WebResourceTextEncodingName";
static NSString * const WebResourceResponseKey = @"WebResourceResponse";

@interface DTWebResource ()

@property(nonatomic, retain, readwrite) NSData *data;
@property(nonatomic, retain, readwrite) NSString *frameName;
@property(nonatomic, retain, readwrite) NSString *mimeType;
@property(nonatomic, retain, readwrite) NSURL *url;
@property(nonatomic, retain, readwrite) NSString *textEncodingName;

@end


@implementation DTWebResource

+ (DTWebResource *)webResourceWithDictionary:(NSDictionary *)dictionary
{
	return [[[DTWebResource alloc] initWithDictionary:dictionary] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
	NSData *data = nil;
	NSString *frameName = nil;
	NSString *mimeType = nil;
	NSURL *url = nil;
	NSString *textEncodingName = nil;
	
	data = [dictionary objectForKey:WebResourceDataKey];
	frameName = [dictionary objectForKey:WebResourceFrameNameKey]; 
	mimeType = [dictionary objectForKey:WebResourceMIMETypeKey];
	url = [NSURL URLWithString:[dictionary objectForKey:WebResourceURLKey]];
	textEncodingName = [dictionary objectForKey:WebResourceTextEncodingNameKey];
	
	// if we wanted to, here's the decoded response
//		NSData *data2 = [dictionary objectForKey:WebResourceResponseKey];
//		if (data2)
//		{
//			NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data2] autorelease];
//			NSHTTPURLResponse *response = [unarchiver decodeObjectForKey:WebResourceResponseKey];
//			NSLog(@"%@", [response allHeaderFields]);
//		}
	
    return [self initWithData:data URL:url MIMEType:mimeType textEncodingName:textEncodingName frameName:frameName];
}

- (id)initWithData:(NSData *)data URL:(NSURL *)URL MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName frameName:(NSString *)frameName
{
	self = [super init];
	
	if (self)
	{
		self.data = data;
		self.url = URL;
		self.mimeType = MIMEType;
		self.textEncodingName = textEncodingName;
		self.frameName = frameName;
	}
	
	return self;
}

- (void)dealloc
{
	[_data release];
	[_url release];
	[_mimeType release];
	[_textEncodingName release];
	[_frameName release];
	
	[super dealloc];
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	if (_data)
	{
		[tmpDict setObject:_data forKey:WebResourceDataKey];
	}
	
	if (_frameName)
	{
		[tmpDict setObject:_frameName forKey:WebResourceFrameNameKey];
	}
	
	if (_mimeType)
	{
		[tmpDict setObject:_mimeType forKey:WebResourceMIMETypeKey];
	}

	if (_textEncodingName)
	{
		[tmpDict setObject:_textEncodingName forKey:WebResourceTextEncodingNameKey];
	}
	
	if (_url)
	{
		[tmpDict setObject:[_url absoluteString] forKey:WebResourceURLKey];
	}
	
	// ignoring the NSURLResponse for now
	
	return tmpDict;
}

- (UIImage *)image
{
	if (![_mimeType hasPrefix:@"image"])
	{
		return nil;
	}
	
	return [UIImage imageWithData:_data];
}

#pragma mark Properties

@synthesize data = _data;
@synthesize frameName = _frameName;
@synthesize mimeType = _mimeType;
@synthesize url = _url;
@synthesize textEncodingName = _textEncodingName;

@end
