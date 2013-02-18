//
//  NSAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"

#import "NSMutableDictionary+DTRichText.h"
#import "DTHTMLElement.h"
#import "DTHTMLElementText.h"
#import "DTTextAttachment.h"
#import "DTCoreTextParagraphStyle.h"
#import "DTUtils.h"

@implementation NSAttributedString (DTRichText)

- (NSDictionary *)typingAttributesForRange:(NSRange)range
{
	NSInteger index = 0;
	
	if (range.length)
	{
		// range = first character of range
		index = range.location;
	}
	else
	{
		if (range.location>0)
		{
			index = range.location - 1;
			
			// if that belongs to previous line we prefer current index
			if ([[self string] characterAtIndex:index] == '\n')
			{
				index++;
			}
		}
	}
	
	if (index >= [self length])
	{
		return nil;
	}
	
	NSDictionary *attributes = [self attributesAtIndex:index effectiveRange:NULL];
	
	if ([attributes hasAttachment])
	{
		// make copy without attachment
		NSMutableDictionary *tmpDict = [attributes mutableCopy];
		[tmpDict removeAttachment];
		
		return tmpDict;
	}
	
	return attributes;
}

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize
{
	DTTextAttachment *attachment = [[DTTextAttachment alloc] init];
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
	
	DTHTMLElement *element = [[DTHTMLElement alloc] init];
	element.textAttachment = attachment;
	
	return [element attributedString];
}

+ (NSAttributedString *)attributedStringWithURL:(NSURL *)URL
{
	DTHTMLElementText *element = [[DTHTMLElementText alloc] init];
	element.link = URL;
	element.underlineStyle = kCTUnderlineStyleSingle;
	element.textColor = [UIColor blueColor];
	element.text = [URL absoluteString];
	
	return [element attributedString];
}

@end
