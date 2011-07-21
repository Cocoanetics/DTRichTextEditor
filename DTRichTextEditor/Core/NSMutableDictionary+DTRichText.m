//
//  NSMutableDictionary+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+DTRichText.h"
#import "DTCoreTextFontDescriptor.h"

@implementation NSMutableDictionary (DTRichText)

- (BOOL)isBold
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	return desc.boldTrait;
}

- (BOOL)isItalic
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	return desc.italicTrait;
}

- (BOOL)isUnderline
{
	return [[self objectForKey:(id)kCTUnderlineStyleAttributeName] integerValue]!=kCTUnderlineStyleNone;
}

- (void)toggleBold
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	desc.fontFamily = (NSString *)family;
	CFRelease(family);
	
	desc.fontName = nil;
	
	desc.boldTrait = !desc.boldTrait;

	CTFontRef newFont = [desc newMatchingFont];
	[self setObject:(id)newFont forKey:(id)kCTFontAttributeName];
	CFRelease(newFont);
}

- (void)toggleItalic
{
	CTFontRef currentFont = (CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	desc.fontFamily = (NSString *)family;
	CFRelease(family);
	
	desc.fontName = nil;
	
	desc.italicTrait = !desc.italicTrait;
	
	CTFontRef newFont = [desc newMatchingFont];
	[self setObject:(id)newFont forKey:(id)kCTFontAttributeName];
	CFRelease(newFont);
}

- (void)toggleUnderline
{
	if ([self isUnderline])
	{
		[self removeObjectForKey:(id)kCTUnderlineStyleAttributeName];
	}
	else
	{
		[self setObject:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
	}
}

@end
