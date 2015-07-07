//
//  NSMutableDictionary+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>

#import "NSMutableDictionary+DTRichText.h"

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

- (void)removeUnderlineStyle
{
	[self removeObjectForKey:(id)kCTUnderlineStyleAttributeName];
	
	if (DTCoreTextModernAttributesPossible())
	{
		[self removeObjectForKey:NSUnderlineStyleAttributeName];
	}
}

- (void)toggleStrikethrough
{
	if ([self isStrikethrough])
	{
		[self removeObjectForKey:DTStrikeOutAttribute];
	}
	else
	{
		[self setObject:[NSNumber numberWithBool:YES] forKey:DTStrikeOutAttribute];
	}
}

- (void)setFontFromFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    CTFontRef currentFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
    
    if (!currentFont)
    {
        return;
    }
    
    CTFontRef newFont = [fontDescriptor newMatchingFont];
    [self setObject:CFBridgingRelease(newFont) forKey:(id)kCTFontAttributeName];
}


- (void)updateParagraphSpacing:(CGFloat)paragraphSpacing
{
    CTParagraphStyleRef p = (__bridge CTParagraphStyleRef)([self objectForKey:(id)kCTParagraphStyleAttributeName]);
    
    DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:p];
    
    if (paragraphSpacing == paragraphStyle.paragraphSpacing)
    {
        return;
    }
    
    paragraphStyle.paragraphSpacing = paragraphSpacing;
    
    CTParagraphStyleRef newStyle = [paragraphStyle createCTParagraphStyle];
    [self setObject:CFBridgingRelease(newStyle) forKey:(id)kCTParagraphStyleAttributeName];
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

- (void)setForegroundColor:(UIColor *)color
{
	if (color)
	{
        [self setObject:(id)[color CGColor] forKey:(id)kCTForegroundColorAttributeName];
	}
	else
	{
		[self removeObjectForKey:(id)kCTForegroundColorAttributeName];
	}
}


- (void)removeAttachment
{
	[self removeObjectForKey:(id)kCTRunDelegateAttributeName];
	[self removeObjectForKey:@"DTAttachmentParagraphSpacing"];
	[self removeObjectForKey:NSAttachmentAttributeName];
}

- (void)removeListPrefixField
{
    NSString *field = [self objectForKey:DTFieldAttribute];
    
    if ([field isEqualToString:DTListPrefixField])
    {
        [self removeObjectForKey:DTFieldAttribute];
    }
}

@end
