//
//  DTHTMLWriter+DTWebArchive.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 23.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTHTMLWriter+DTWebArchive.h"

#import "DTWebArchive.h"
#import "DTWebResource.h"

#import "DTCoreText.h"

@class DTWebArchive;

@implementation DTHTMLWriter (DTWebArchive)

- (DTWebArchive *)webArchive
{
	// this string does the general generation and also includes optional text size scaling
	NSString *htmlString = [self HTMLString];
	
	NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableArray *subresources = nil;
	
	NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"contentType == %d", DTTextAttachmentTypeImage];
	
	NSArray *images = [self.attributedString textAttachmentsWithPredicate:imagePredicate];
	
	if ([images count])
	{
		subresources = [NSMutableArray array];
		for (DTTextAttachment *oneAttachment in images)
		{
			// only add web resources for images that are not data URLs and that have a contentURL
			if (oneAttachment.contents && !oneAttachment.contentURL)
			{
				// this is an image in a data URL, that's already represented in the HTML
				continue;
			}
			
			NSData *data = UIImagePNGRepresentation(oneAttachment.contents);
			
			if (data)
			{
				DTWebResource *resource = [[DTWebResource alloc] initWithData:data URL:oneAttachment.contentURL MIMEType:@"image/png" textEncodingName:nil frameName:nil];
				[subresources addObject:resource];
			}
		}
	}
	
	DTWebResource *mainResource = [[DTWebResource alloc] initWithData:data URL:nil MIMEType:@"text/html" textEncodingName:@"UTF8" frameName:nil];
	DTWebArchive *newArchive = [[DTWebArchive alloc] initWithMainResource:mainResource subresources:subresources subframeArchives:nil];
	
	return newArchive;
}

@end
