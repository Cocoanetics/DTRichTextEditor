//
//  NSAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"

#import "DTHTMLElement.h"
#import "DTTextAttachment.h"
#import "DTCoreTextParagraphStyle.h"

#import "CGUtils.h"

@implementation NSAttributedString (DTRichText)

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize
{
	DTTextAttachment *attachment = [[[DTTextAttachment alloc] init] autorelease];
	attachment.contents = (id)image;
	attachment.originalSize = image.size;
	attachment.contentType = DTTextAttachmentTypeImage;

	CGSize displaySize = image.size;
	if (!CGSizeEqualToSize(maxDisplaySize, CGSizeZero))
	{
		if (maxDisplaySize.width < image.size.width || maxDisplaySize.height < image.size.height)
		{
			displaySize = sizeThatFitsKeepingAspectRatio(image.size,maxDisplaySize);
		}
	}
	attachment.displaySize = displaySize;
	
	DTHTMLElement *element = [[[DTHTMLElement alloc] init] autorelease];
	element.textAttachment = attachment;
	
	return [element attributedString];
}

+ (NSAttributedString *)attributedStringWithURL:(NSURL *)url
{
	DTHTMLElement *element = [[[DTHTMLElement alloc] init] autorelease];
	element.link = url;
	element.underlineStyle = kCTUnderlineStyleSingle;
	element.textColor = [UIColor blueColor];
	element.text = [url absoluteString];
	
	return [element attributedString];
}

@end
