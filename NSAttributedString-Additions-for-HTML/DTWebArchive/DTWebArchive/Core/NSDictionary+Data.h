//
//  NSDictionary+Data.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Data)

+ (NSDictionary *)dictionaryWithData:(NSData *)data;

- (id)initWithData:(NSData *)data;

- (NSData *)dataRepresentation;

@end
