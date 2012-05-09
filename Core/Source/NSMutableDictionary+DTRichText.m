//
//  NSMutableDictionary+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "NSMutableDictionary+DTRichText.h"
#import "DTCoreTextFontDescriptor.h"
#import "DTCoreTextConstants.h"

@implementation NSMutableDictionary (DTRichText)

- (void)toggleBold
{
	CTFontRef currentFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	if (!currentFont)
	{
		return;
	}
	
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	desc.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	desc.fontName = nil;
	
	desc.boldTrait = !desc.boldTrait;

	CTFontRef newFont = [desc newMatchingFont];
	[self setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
	CFRelease(newFont);
}

- (void)toggleItalic
{
	CTFontRef currentFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	if (!currentFont)
	{
		return;
	}
	
	DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	desc.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	desc.fontName = nil;
	
	desc.italicTrait = !desc.italicTrait;
	
	CTFontRef newFont = [desc newMatchingFont];
	[self setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
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

- (void)toggleHighlightWithColor:(UIColor *)color
{
    CGColorRef backgroundColor = (__bridge CGColorRef)[self objectForKey:DTBackgroundColorAttribute];
    
    if (backgroundColor)
    {
        // trying to set the same color again removes it
        
        UIColor *setColor = [UIColor colorWithCGColor:backgroundColor];
        
        if ([color isEqual:setColor])
        {
            [self removeObjectForKey:DTBackgroundColorAttribute];
        }
    }
    else 
    {
        [self setObject:(id)[color CGColor] forKey:DTBackgroundColorAttribute];
    }
}


- (void)removeAttachment
{
	[self removeObjectForKey:(id)kCTRunDelegateAttributeName];
	[self removeObjectForKey:@"DTAttachmentParagraphSpacing"];
	[self removeObjectForKey:NSAttachmentAttributeName];
}

@end
