//
//  NSMutableAttributedString+HTML.m
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 4/14/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "NSMutableAttributedString+HTML.h"

#import <CoreText/CoreText.h>
#import "DTCoreTextParagraphStyle.h"

//#import "DTRangedAttributesOptimizer.h"


@implementation NSMutableAttributedString (HTML)


// apends a plain string extending the attributes at this position
- (void)appendString:(NSString *)string
{
	NSInteger length = [self length];
	
	NSDictionary *previousAttributes = nil;
	
	if (length)
	{
		// get attributes from last character
		previousAttributes = [self attributesAtIndex:length-1 effectiveRange:NULL];
	}
	
	NSAttributedString *tmpString = [[NSAttributedString alloc] initWithString:string attributes:previousAttributes];
	[self appendAttributedString:tmpString];
	[tmpString release];
}

- (void)appendString:(NSString *)string withParagraphStyle:(DTCoreTextParagraphStyle *)paragraphStyle
{
	NSMutableDictionary *attributes = nil;
	
	if (paragraphStyle)
	{
		attributes = [NSMutableDictionary dictionary];
		CTParagraphStyleRef newParagraphStyle = [paragraphStyle createCTParagraphStyle];
		[attributes setObject:(id)newParagraphStyle forKey:(id)kCTParagraphStyleAttributeName];
		CFRelease(newParagraphStyle);
	}
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	[self appendAttributedString:attributedString];
	[attributedString release];
}

// appends a string without any attributes
- (void)appendNakedString:(NSString *)string
{
	[self appendString:string withParagraphStyle:nil];
}

@end
