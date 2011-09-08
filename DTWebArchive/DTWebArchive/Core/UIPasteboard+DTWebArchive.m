//
//  UIPasteboard+UIPasteboard_DTWebArchive.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "UIPasteboard+DTWebArchive.h"

#import "DTWebArchive.h"
#import "NSDictionary+Data.h"

@implementation UIPasteboard (DTWebArchive)

- (DTWebArchive *)webArchive
{
	NSData *data = [self dataForPasteboardType:WebArchivePboardType];
	
	DTWebArchive *webArchive = [[DTWebArchive alloc] initWithData:data];
	
	return [webArchive autorelease];
}

- (void)setWebArchive:(DTWebArchive *)webArchive
{
	NSData *data = [[webArchive dictionaryRepresentation] dataRepresentation];
	
	[self setData:data forPasteboardType:WebArchivePboardType];
}

@end
