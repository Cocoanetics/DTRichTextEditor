//
//  DTWebResource.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTWebResource : NSObject <NSKeyedUnarchiverDelegate>
{
	NSData *_data;
	NSString *_frameName;
	NSString *_mimeType;
	NSURL *_url;
	NSString *_textEncodingName;
}

+ (DTWebResource *)webResourceWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithData:(NSData *)data URL:(NSURL *)URL MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName frameName:(NSString *)frameName;

- (NSDictionary *)dictionaryRepresentation;

@property(nonatomic, retain, readonly) NSData *data;
@property(nonatomic, retain, readonly) NSString *frameName;
@property(nonatomic, retain, readonly) NSString *mimeType;
@property(nonatomic, retain, readonly) NSURL *url;
@property(nonatomic, retain, readonly) NSString *textEncodingName;

@end
