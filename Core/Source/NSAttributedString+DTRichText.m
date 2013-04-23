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
#import "DTTextHTMLElement.h"
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
	
	NSMutableDictionary *attributes = [[self attributesAtIndex:index effectiveRange:NULL] mutableCopy];
	
    // remove attachments
    [attributes removeAttachment];
    
    // we don't want to type with the list prefix
    [attributes removeListPrefixField];
	
	return attributes;
}

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize
{
	DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc] initWithElement:nil options:nil];
	attachment.image = image;
	attachment.originalSize = image.size;

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
	DTTextHTMLElement *element = [[DTTextHTMLElement alloc] init];
	element.link = URL;
	element.underlineStyle = kCTUnderlineStyleSingle;
	element.textColor = [UIColor blueColor];
	element.text = [URL absoluteString];
	
	return [element attributedString];
}

- (NSRange)rangeOfListPrefixAtIndex:(NSUInteger)index
{
    if (index<[self length])
    {
        // get range of prefix
        NSRange fieldRange;
        NSString *fieldAttribute = [self attribute:DTFieldAttribute atIndex:index effectiveRange:&fieldRange];
        
        if (fieldAttribute)
        {
            return fieldRange;
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

@end
