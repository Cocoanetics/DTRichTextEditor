//
//  NSMutableAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableAttributedString+DTRichText.h"

#import "DTTextAttachment.h"
#import <CoreText/CoreText.h>
#import "NSAttributedStringRunDelegates.h"
#import "NSString+HTML.h"


@implementation NSMutableAttributedString (DTRichText)

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
		}
	}
	
	if (index >= [self length])
	{
		return nil;
	}
	
	return [self attributesAtIndex:index effectiveRange:NULL];
}

- (void)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment
{
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	// need run delegate for sizing
	CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate((id)attachment);
	[attributes setObject:(id)embeddedObjectRunDelegate forKey:(id)kCTRunDelegateAttributeName];
	CFRelease(embeddedObjectRunDelegate);
	
	// add attachment
	[attributes setObject:attachment forKey:@"DTTextAttachment"];
	
	NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:UNICODE_OBJECT_PLACEHOLDER attributes:attributes];
	
	[self replaceCharactersInRange:range withAttributedString:tmpStr];
	
	[tmpStr release];
	[attributes release];
}


@end
