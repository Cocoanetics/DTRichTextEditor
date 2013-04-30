//
//  NSDictionary+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSDictionary+DTRichText.h"

#import <CoreText/CoreText.h>
#import "DTCoreTextFontDescriptor.h"
#import "DTCoreTextConstants.h"

@implementation NSDictionary (DTRichText)

- (BOOL)isBold
{
	CTFontRef currentFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	if (!currentFont)
	{
		return NO;
	}
	
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	return desc.boldTrait;
}

- (BOOL)isItalic
{
	CTFontRef currentFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	if (!currentFont)
	{
		return NO;
	}
	
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	return desc.italicTrait;
}

- (BOOL)isUnderline
{
	return [[self objectForKey:(id)kCTUnderlineStyleAttributeName] integerValue]!=kCTUnderlineStyleNone;
}

- (BOOL)hasAttachment
{
	return [self objectForKey:NSAttachmentAttributeName]!=nil;
}

- (DTCoreTextParagraphStyle *)paragraphStyle
{
    CTParagraphStyleRef ctParagraphStyle = (__bridge CTParagraphStyleRef)([self objectForKey:(id)kCTParagraphStyleAttributeName]);
	
	if (ctParagraphStyle)
	{
		return [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:ctParagraphStyle];
	}
	
	// try NSParagraphStyle
	
	if (![NSParagraphStyle class])
	{
		// unknown class
		return nil;
	}
	
	NSParagraphStyle *nsParagraphStyle = [self objectForKey:NSParagraphStyleAttributeName];
	return [DTCoreTextParagraphStyle paragraphStyleWithNSParagraphStyle:nsParagraphStyle];
}

@end
