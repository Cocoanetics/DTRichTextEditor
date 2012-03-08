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

// use smaller list indent on iPhone OS
#if TARGET_OS_IPHONE
#define SPECIAL_LIST_INDENT		27.0f
#else
#define SPECIAL_LIST_INDENT		36.0f
#endif

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

+ (NSAttributedString *)prefixForListItemWithCounter:(NSUInteger)listCounter listStyle:(DTCSSListStyle *)listStyle attributes:(NSDictionary *)attributes
{
	// get existing values from attributes
	CTParagraphStyleRef paraStyle = (__bridge CTParagraphStyleRef)[attributes objectForKey:(id)kCTParagraphStyleAttributeName];
	CTFontRef font = (__bridge CTFontRef)[attributes objectForKey:(id)kCTFontAttributeName];
	CGColorRef textColor = (__bridge CGColorRef)[attributes objectForKey:(id)kCTForegroundColorAttributeName];
	
	DTCoreTextFontDescriptor *fontDescriptor = nil;
	DTCoreTextParagraphStyle *paragraphStyle = nil;
	
	if (paraStyle)
	{
		paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paraStyle];
		
		paragraphStyle.tabStops = nil;
		
		paragraphStyle.headIndent = SPECIAL_LIST_INDENT;
		paragraphStyle.paragraphSpacing = 0;
		
		// first tab is to right-align bullet, numbering against
		CGFloat tabOffset = paragraphStyle.headIndent - 5.0f*1.0; // TODO: change with font size
		[paragraphStyle addTabStopAtPosition:tabOffset alignment:kCTRightTextAlignment];
		
		// second tab is for the beginning of first line after bullet
		[paragraphStyle addTabStopAtPosition:paragraphStyle.headIndent alignment:	kCTLeftTextAlignment];	
	}

	if (font)
	{
		fontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:font];
	}
	
	NSMutableDictionary *newAttributes = [NSMutableDictionary dictionary];
	
	if (fontDescriptor)
	{
		// make a font without italic or bold
		DTCoreTextFontDescriptor *fontDesc = [fontDescriptor copy];
		
		fontDesc.boldTrait = NO;
		fontDesc.italicTrait = NO;
		
		CTFontRef font = [fontDesc newMatchingFont];
		
		[newAttributes setObject:CFBridgingRelease(font) forKey:(id)kCTFontAttributeName];
	}
	
	// text color for bullet same as text
	if (textColor)
	{
		[newAttributes setObject:(__bridge id)textColor forKey:(id)kCTForegroundColorAttributeName];
	}
	
	// add paragraph style (this has the tabs)
	if (paragraphStyle)
	{
		CTParagraphStyleRef newParagraphStyle = [paragraphStyle createCTParagraphStyle];
		[newAttributes setObject:CFBridgingRelease(newParagraphStyle) forKey:(id)kCTParagraphStyleAttributeName];
	}
	
	if (listStyle)
	{
		[newAttributes setObject:[NSArray arrayWithObject:listStyle] forKey:DTTextListsAttribute];
	}
	
	NSString *prefix = [listStyle prefixWithCounter:listCounter];
	
	if (prefix)
	{
		DTImage *image = nil;
		
		if (listStyle.imageName)
		{
			image = [DTImage imageNamed:listStyle.imageName];
			
			if (!image)
			{
				// image invalid
				listStyle.imageName = nil;
				
				prefix = [listStyle prefixWithCounter:listCounter];
			}
		}
		
		NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:prefix attributes:newAttributes];
		
		
		if (image)
		{
			// make an attachment for the image
			DTTextAttachment *attachment = [[DTTextAttachment alloc] init];
			attachment.contents = image;
			attachment.contentType = DTTextAttachmentTypeImage;
			attachment.displaySize = image.size;
			
#if TARGET_OS_IPHONE
			// need run delegate for sizing
			CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate(attachment);
			[newAttributes setObject:CFBridgingRelease(embeddedObjectRunDelegate) forKey:(id)kCTRunDelegateAttributeName];
#endif
			
			// add attachment
			[newAttributes setObject:attachment forKey:NSAttachmentAttributeName];				
			
			if (listStyle.position == DTCSSListStylePositionInside)
			{
				[tmpStr setAttributes:newAttributes range:NSMakeRange(2, 1)];
			}
			else
			{
				[tmpStr setAttributes:newAttributes range:NSMakeRange(1, 1)];
			}
		}
		
		return tmpStr;
	}
	
	return nil;
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
