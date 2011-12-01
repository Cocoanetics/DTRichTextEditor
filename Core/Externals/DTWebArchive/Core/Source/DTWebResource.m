//
//  DTWebResource.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTWebResource.h"

NSString *WebResourceDataKey = @"WebResourceData";
NSString *WebResourceFrameNameKey = @"WebResourceFrameName";
NSString *WebResourceMIMETypeKey = @"WebResourceMIMEType";
NSString *WebResourceURLKey = @"WebResourceURL";
NSString *WebResourceTextEncodingNameKey =  @"WebResourceTextEncodingName";
NSString *WebResourceResponseKey = @"WebResourceResponse";

@interface DTWebResource ()

@property(nonatomic, retain, readwrite) NSData *data;
@property(nonatomic, retain, readwrite) NSString *frameName;
@property(nonatomic, retain, readwrite) NSString *MIMEType;
@property(nonatomic, retain, readwrite) NSURL *URL;
@property(nonatomic, retain, readwrite) NSString *textEncodingName;

@end


@implementation DTWebResource

- (id)initWithData:(NSData *)data URL:(NSURL *)URL MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName frameName:(NSString *)frameName
{
	self = [super init];
	
	if (self)
	{
		self.data = data;
		self.URL = URL;
		self.MIMEType = MIMEType;
		self.textEncodingName = textEncodingName;
		self.frameName = frameName;
	}
	
	return self;
}


#pragma mark Properties

@synthesize data = _data;
@synthesize frameName = _frameName;
@synthesize MIMEType = _MIMEType;
@synthesize URL = _URL;
@synthesize textEncodingName = _textEncodingName;

@end


@implementation DTWebResource (Dictionary)

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
	
	if (_MIMEType)
	{
		[tmpDict setObject:_MIMEType forKey:WebResourceMIMETypeKey];
	}
	
	if (_textEncodingName)
	{
		[tmpDict setObject:_textEncodingName forKey:WebResourceTextEncodingNameKey];
	}
	
	if (_URL)
	{
		[tmpDict setObject:[_URL absoluteString] forKey:WebResourceURLKey];
	}
	
	// ignoring the NSURLResponse for now
	
	return tmpDict;
}


@end
