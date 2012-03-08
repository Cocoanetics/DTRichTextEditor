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
#import "DTTextAttachment.h"
#import "DTCoreTextParagraphStyle.h"
#import "CGUtils.h"

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

+ (NSAttributedString *)attributedStringWithURL:(NSURL *)url
{
	DTHTMLElement *element = [[DTHTMLElement alloc] init];
	element.link = url;
	element.underlineStyle = kCTUnderlineStyleSingle;
	element.textColor = [UIColor blueColor];
	element.text = [url absoluteString];
	
	return [element attributedString];
}

- (NSString *)dumpString
{
	NSMutableString *dumpOutput = [NSMutableString string];
	NSDictionary *attributes = nil;
	NSRange effectiveRange = NSMakeRange(0, 0);
	
		while ((attributes = [self attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange]))
		{
			NSString *plainString = [[self attributedSubstringFromRange:effectiveRange] string];
			[dumpOutput appendFormat:@"'%@' (%d, %d), %@\n\n", plainString, effectiveRange.location, effectiveRange.length, attributes];
			effectiveRange.location += effectiveRange.length;
			
			if (effectiveRange.location >= [self length])
			{
				break;
			}
		}
	return dumpOutput;
}

@end
