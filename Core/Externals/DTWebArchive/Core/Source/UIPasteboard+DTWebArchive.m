//
//  UIPasteboard+DTWebArchive.m
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "UIPasteboard+DTWebArchive.h"

#import "DTWebArchive.h"

@implementation UIPasteboard (DTWebArchive)

- (DTWebArchive *)webArchive
{
	NSData *data = [self dataForPasteboardType:WebArchivePboardType];
	
    if (!data)
    {
        return nil;
    }
    
	return [[DTWebArchive alloc] initWithData:data];
}

- (void)setWebArchive:(DTWebArchive *)webArchive
{
	[self setData:[webArchive data] forPasteboardType:WebArchivePboardType];
}

@end
