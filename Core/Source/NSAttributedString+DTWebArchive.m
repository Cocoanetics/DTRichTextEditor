//
//  DTWebArchive.m
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 9/6/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>
#import <DTWebArchive/DTWebArchive.h>
#import <DTWebArchive/DTWebResource.h>

#import "NSAttributedString+DTWebArchive.h"
#import "DTWebResource+DTRichText.h"

@implementation NSAttributedString (DTWebArchive)

- (id)initWithWebArchive:(DTWebArchive *)webArchive options:(NSDictionary *)options documentAttributes:(NSDictionary **)dict
{
	// only proceed if this is indeed HTML
	if (![webArchive.mainResource.MIMEType isEqualToString:@"text/html"])
	{
		return nil;
	}
	
	// build the options
	NSMutableDictionary *localOptions = [NSMutableDictionary dictionary];
	
	if (options)
	{
		[localOptions addEntriesFromDictionary:options];
	}
	
	// base URL overrides
	if (webArchive.mainResource.URL)
	{
		[localOptions setObject:webArchive.mainResource.URL forKey:NSBaseURLDocumentOption];
	}
	
	// text encoding overrides
	if (webArchive.mainResource.textEncodingName)
	{
		[localOptions setObject:webArchive.mainResource.textEncodingName forKey:NSTextEncodingNameDocumentOption];
	}
	
	// make attributed string
	NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithHTMLData:webArchive.mainResource.data options:localOptions documentAttributes:dict];
	
	
	// if data is available for image attachments fill it in
	for (DTWebResource *oneResource in webArchive.subresources)
	{
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL.absoluteString == %@", [oneResource.URL absoluteString]];
		
		// possibly multiple attachments with same URL
		NSArray *attachments = [tmpStr textAttachmentsWithPredicate:pred class:[DTImageTextAttachment class]];
		
		UIImage *image = [oneResource image];
		
		if (image)
		{
			for (DTImageTextAttachment *oneAttachment in attachments)
			{
				// this avoids unnecessary lazy loading
				oneAttachment.image = image;
			}
		}
	}
	
	return tmpStr;
}

- (DTWebArchive *)webArchive
{
	NSString *htmlString = [self htmlString];
	NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableArray *subresources = nil;
	
	NSArray *images = [self textAttachmentsWithPredicate:nil class:[DTImageTextAttachment class]];
	
	if ([images count])
	{
		subresources = [NSMutableArray array];
		for (DTImageTextAttachment *oneAttachment in images)
		{
			// only add web resources for images that are not data URLs and that have a contentURL
			if (oneAttachment.image && !oneAttachment.contentURL)
			{
				// this is an image in a data URL, that's already represented in the HTML
				continue;
			}
			
			NSData *data = UIImagePNGRepresentation(oneAttachment.image);
			
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
