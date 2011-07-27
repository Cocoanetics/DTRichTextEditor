//
//  NSDictionary+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+DTRichText.h"

#import <CoreText/CoreText.h>
#import "DTCoreTextFontDescriptor.h"

@implementation NSDictionary (DTRichText)

- (BOOL)isBold
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	if (!currentFont)
	{
		return NO;
	}
	
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	return desc.boldTrait;
}

- (BOOL)isItalic
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
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
	return [self objectForKey:@"DTTextAttachment"]!=nil;
}

@end
