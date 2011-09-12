//
//  DTWebArchive.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTWebResource.h"

extern NSString * WebArchivePboardType;

@interface DTWebArchive : NSObject
{
	DTWebResource *_mainResource;
	NSArray *_subresources;
	NSArray *_subframeArchives;
	NSData *_data;
}

@property (nonatomic, retain, readonly) DTWebResource *mainResource;
@property (nonatomic, retain, readonly) NSArray *subresources;
@property (nonatomic, retain, readonly) NSArray *subframeArchives;
@property (nonatomic, retain, readonly) NSData *data;

- (id)initWithData:(NSData *)data;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithMainResource:(DTWebResource *)mainResource subresources:(NSArray *)subresources subframeArchives:(NSArray *)subframeArchives;

- (NSDictionary *)dictionaryRepresentation;

@end
