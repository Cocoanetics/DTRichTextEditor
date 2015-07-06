//
//  NSAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"
#import "NSMutableDictionary+DTRichText.h"

#import <DTCoreText/DTCoreText.h>
#import <DTFoundation/DTCoreGraphicsUtils.h>

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
	
	NSMutableDictionary *attributes = [[self attributesAtIndex:index effectiveRange:NULL] mutableCopy];
	
    // remove attachments
    [attributes removeAttachment];
    
    // we don't want to type with the list prefix
    [attributes removeListPrefixField];
	
	return attributes;
}

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize
{
    Class ImageAttachmentClass = [DTTextAttachment registeredClassForTagName:@"img"];
    NSAssert([ImageAttachmentClass isSubclassOfClass:[DTImageTextAttachment class]], @"DTRichTextEditor requires DTImageTextAttachment or a subclass of it be registered for 'img' tags.");
    
    DTImageTextAttachment *attachment = [[ImageAttachmentClass alloc] initWithElement:nil options:nil];
    attachment.image = image;
    attachment.originalSize = image.size;

	CGSize displaySize = image.size;
	if (!CGSizeEqualToSize(maxDisplaySize, CGSizeZero))
	{
		if (maxDisplaySize.width < image.size.width || maxDisplaySize.height < image.size.height)
		{
			displaySize = DTCGSizeThatFitsKeepingAspectRatio(image.size,maxDisplaySize);
		}
	}
	attachment.displaySize = displaySize;
	
	DTHTMLElement *element = [[DTHTMLElement alloc] init];
	element.textAttachment = attachment;
	
	return [element attributedString];
}

+ (NSAttributedString *)attributedStringWithURL:(NSURL *)URL
{
	DTTextHTMLElement *element = [[DTTextHTMLElement alloc] init];
	element.link = URL;
	element.underlineStyle = kCTUnderlineStyleSingle;
	element.textColor = [UIColor blueColor];
	element.text = [URL absoluteString];
	
	return [element attributedString];
}

@end
