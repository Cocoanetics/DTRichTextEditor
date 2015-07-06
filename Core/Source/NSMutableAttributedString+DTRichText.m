//
//  NSMutableAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>
#import <DTFoundation/NSString+DTUtilities.h>
//#import <DTCoreText/NSString+Paragraphs.h>

#import "NSAttributedString+DTRichText.h"
#import "NSMutableAttributedString+DTRichText.h"
//#import "NSMutableAttributedString+HTML.h"
#import "NSMutableDictionary+DTRichText.h"

//#import "DTTextAttachment.h"
//#import "NSAttributedStringRunDelegates.h"
//#import "NSString+HTML.h"

//#import "DTCoreTextFontDescriptor.h"
//#import "DTCoreTextParagraphStyle.h"
//#import "DTCoreTextConstants.h"

//#import "UIFont+DTCoreText.h"
#import "DTRichTextEditorConstants.h"


@implementation NSMutableAttributedString (DTRichText)

- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	[self beginEditing];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
    if (inParagraph)
    {
        if (range.location>0)
        {
            NSInteger index = range.location-1;
            
            unichar character = [[self string] characterAtIndex:index];
            
            if (character != '\n')
            {
                needsParagraphBefore = YES;
            }
        }
        
        if (range.location+range.length<[self length])
        {
            NSUInteger index = range.location+range.length;
            
            unichar character = [[self string] characterAtIndex:index];
            
            if (character != '\n')
            {
                needsParagraphAfter = YES;
            }
        }
    }
	
	NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
	
	if (needsParagraphBefore)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	NSMutableDictionary *objectAttributes = [attributes mutableCopy];
	
	// need run delegate for sizing
	CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate((id)attachment);
	[objectAttributes setObject:(__bridge id)embeddedObjectRunDelegate forKey:(id)kCTRunDelegateAttributeName];
	CFRelease(embeddedObjectRunDelegate);
	
	// add attachment
	[objectAttributes setObject:attachment forKey:NSAttachmentAttributeName];
	
	
	NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:UNICODE_OBJECT_PLACEHOLDER attributes:objectAttributes];
	[tmpAttributedString appendAttributedString:tmpStr];
	
	
	if (needsParagraphAfter)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	
	[self replaceCharactersInRange:range withAttributedString:tmpAttributedString];
	
	[self endEditing];
	
    return [tmpAttributedString length];
}

- (void)toggleBoldInRange:(NSRange)range
{
	// first character determines current boldness
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	[self beginEditing];
	
	CTFontRef currentFont = (__bridge CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *typingFontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	typingFontDescriptor.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	typingFontDescriptor.fontName = nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range))
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		CTFontRef currentFont = (__bridge CTFontRef)[attrs objectForKey:(id)kCTFontAttributeName];
		
		if (currentFont)
		{
			DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
			
			// need to replace name with family
			CFStringRef family = CTFontCopyFamilyName(currentFont);
			desc.fontFamily = (__bridge NSString *)family;
			CFRelease(family);
			
			desc.fontName = nil;
			
			desc.boldTrait = !typingFontDescriptor.boldTrait;
			CTFontRef newFont = [desc newMatchingFont];
			[attrs setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
			CFRelease(newFont);
			
			if (attrRange.location < range.location)
			{
				attrRange.length -= (range.location - attrRange.location);
				attrRange.location = range.location;
			}
			
			if (NSMaxRange(attrRange)>NSMaxRange(range))
			{
				attrRange.length = NSMaxRange(range) - attrRange.location;
			}
			
			[self setAttributes:attrs range:attrRange];
		}
		
        index += attrRange.length;
    }
	
	[self endEditing];
}


- (void)toggleItalicInRange:(NSRange)range
{
	// first character determines current italic status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	[self beginEditing];
	
	CTFontRef currentFont = (__bridge CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *typingFontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	typingFontDescriptor.fontFamily = (__bridge NSString *)family;
	CFRelease(family);
	
	typingFontDescriptor.fontName = nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range))
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		CTFontRef currentFont = (__bridge CTFontRef)[attrs objectForKey:(id)kCTFontAttributeName];
		
		if (currentFont)
		{
			DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
			
			// need to replace name with family
			CFStringRef family = CTFontCopyFamilyName(currentFont);
			desc.fontFamily = (__bridge NSString *)family;
			CFRelease(family);
			
			desc.fontName = nil;
			
			desc.italicTrait = !typingFontDescriptor.italicTrait;
			CTFontRef newFont = [desc newMatchingFont];
			[attrs setObject:(__bridge id)newFont forKey:(id)kCTFontAttributeName];
			CFRelease(newFont);
			
			if (attrRange.location < range.location)
			{
				attrRange.length -= (range.location - attrRange.location);
				attrRange.location = range.location;
			}
			
			if (NSMaxRange(attrRange)>NSMaxRange(range))
			{
				attrRange.length = NSMaxRange(range) - attrRange.location;
			}
			
			[self setAttributes:attrs range:attrRange];
		}
		
        index += attrRange.length;
    }
	
	[self endEditing];
}

- (void)toggleUnderlineInRange:(NSRange)range
{
	[self beginEditing];
	
	// first character determines current italic status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	BOOL isUnderline = [currentAttributes objectForKey:(id)kCTUnderlineStyleAttributeName]!=nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range))
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		
		if (isUnderline)
		{
			[attrs removeObjectForKey:(id)kCTUnderlineStyleAttributeName];
		}
		else
		{
			[attrs setObject:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] forKey:(id)kCTUnderlineStyleAttributeName];
		}
		if (attrRange.location < range.location)
		{
			attrRange.length -= (range.location - attrRange.location);
			attrRange.location = range.location;
		}
		
		if (NSMaxRange(attrRange)>NSMaxRange(range))
		{
			attrRange.length = NSMaxRange(range) - attrRange.location;
		}
		
		[self setAttributes:attrs range:attrRange];
		
        index += attrRange.length;
    }
	
	[self endEditing];
}

- (void)toggleStrikethroughInRange:(NSRange)range
{
	[self beginEditing];
	
	// first character determines current italic status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	BOOL isStrikethrough = [currentAttributes isStrikethrough];
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range))
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		
		if (isStrikethrough)
		{
			[attrs removeObjectForKey:DTStrikeOutAttribute];
		}
		else
		{
			[attrs setObject:[NSNumber numberWithBool:YES] forKey:DTStrikeOutAttribute];
		}
		if (attrRange.location < range.location)
		{
			attrRange.length -= (range.location - attrRange.location);
			attrRange.location = range.location;
		}
		
		if (NSMaxRange(attrRange)>NSMaxRange(range))
		{
			attrRange.length = NSMaxRange(range) - attrRange.location;
		}
		
		[self setAttributes:attrs range:attrRange];
		
        index += attrRange.length;
    }
	
	[self endEditing];
}

- (void)toggleHighlightInRange:(NSRange)range color:(UIColor *)color
{
	[self beginEditing];
	
	// first character determines current highlight status
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
    
    if (!currentAttributes)
    {
        return;
    }
	
	BOOL isHighlighted = [currentAttributes objectForKey:(id)DTBackgroundColorAttribute]!=nil;
	
    NSRange attrRange;
    NSUInteger index=range.location;
    
    while (index < NSMaxRange(range))
    {
        NSMutableDictionary *attrs = [[self attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		
		if (isHighlighted)
		{
			[attrs removeObjectForKey:DTBackgroundColorAttribute];
		}
		else
		{
			if (color)
			{
				[attrs setObject:(id)[color CGColor] forKey:DTBackgroundColorAttribute];
			}
		}
		if (attrRange.location < range.location)
		{
			attrRange.length -= (range.location - attrRange.location);
			attrRange.location = range.location;
		}
		
		if (NSMaxRange(attrRange)>NSMaxRange(range))
		{
			attrRange.length = NSMaxRange(range) - attrRange.location;
		}
		
		[self setAttributes:attrs range:attrRange];
		
        index += attrRange.length;
    }
	
	[self endEditing];
}

- (void)setForegroundColor:(UIColor *)color inRange:(NSRange)range
{
	[self beginEditing];

	[self removeAttribute:(id)kCTForegroundColorAttributeName range:range];
	
	if (color)
	{
		[self addAttribute:(id)kCTForegroundColorAttributeName value:(id)[color CGColor] range:range];
	}
	
	[self endEditing];
}

- (void)toggleHyperlinkInRange:(NSRange)range URL:(NSURL *)URL
{
	[self beginEditing];
	
	// remove existing attributes
	[self removeAttribute:DTLinkAttribute range:range];
	[self removeAttribute:DTGUIDAttribute range:range];
    
	if (URL)
	{
		// we want to set the URL
		[self addAttribute:DTLinkAttribute value:URL range:range];
		[self addAttribute:DTGUIDAttribute value:[NSString stringWithUUID] range:range];
	}
	
	[self endEditing];
}

- (void)replaceFont:(UIFont *)font inRange:(NSRange)range
{
	[self beginEditing];
    
    [self removeAttribute:(id)kCTFontAttributeName range:range];
    
    CTFontRef ctFont = DTCTFontCreateWithUIFont(font);
    [self addAttribute:(id)kCTFontAttributeName value:CFBridgingRelease(ctFont) range:range];
    
	[self endEditing];
}

- (BOOL)enumerateAndUpdateParagraphStylesInRange:(NSRange)range block:(NSMutableAttributedStringParagraphStyleEnumerationBlock)block
{
	NSAssert(block, @"Block cannot be NULL");
	
	NSString *string = [self string];
	
	// extend to entire paragraphs
	NSRange allParagraphsRange = [string rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	NSUInteger index = range.location;
	__block BOOL didChange = NO;
	
	while (index<NSMaxRange(allParagraphsRange))
	{
		NSRange paragraphRange =  [string rangeOfParagraphAtIndex:index];
		
		CTParagraphStyleRef ctParaStyle = (__bridge CTParagraphStyleRef)[self attribute:(id)kCTParagraphStyleAttributeName atIndex:index effectiveRange:NULL];
		
		// make our own mutable paragraph style objects out of that
		DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:ctParaStyle];
		
		__block BOOL stop = NO;
		
		// execute the block
		if (block(paragraphStyle, &stop))
		{
			// YES means we should update
			CTParagraphStyleRef newStyle = [paragraphStyle createCTParagraphStyle];
			
			// remove old, works around old leak
			[self removeAttribute:(id)kCTParagraphStyleAttributeName range:paragraphRange];
			
			[self addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)newStyle range:paragraphRange];
			
			didChange = YES;
			
			CFRelease(newStyle);
			
			if (stop)
			{
				break;
			}
		}
		
		index = NSMaxRange(paragraphRange);
	}
	
	return didChange;
}

- (BOOL)enumerateAndUpdateFontInRange:(NSRange)range block:(NSMutableAttributedStringFontStyleEnumerationBlock)block
{
    NSAssert(block, @"Block cannot be NULL");
    
    __block BOOL didChange = NO;
    
    [self enumerateAttribute:(id)kCTFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        
		 if (value)
		 {
			 DTCoreTextFontDescriptor *descriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:(__bridge CTFontRef)value];
			 
			 BOOL shouldStop = NO;
			 
			 BOOL didChangeRange = block(descriptor, &shouldStop);
			 
			 if (didChangeRange)
			 {
				 CTFontRef newFont = [descriptor newMatchingFont];
				 
				 // remove the old font
				 [self removeAttribute:(id)kCTFontAttributeName range:range];
				 
				 // add the new
				 [self addAttribute:(id)kCTFontAttributeName value:CFBridgingRelease(newFont) range:range];
				 
				 didChange = YES;
			 }
			 
			 *stop = shouldStop;
		 }
		 else
		 {
			 NSLog(@"Warning: In %s, no font attribute for range %@", __PRETTY_FUNCTION__, NSStringFromRange(range));
		 }
    }];
    
    return didChange;
}

- (BOOL)deleteListPrefix
{
    __block BOOL didDeletePrefix = NO;
    
    // get range of prefix
    NSRange fieldRange = [self rangeOfFieldAtIndex:0];
    
    if (fieldRange.location == NSNotFound)
    {
        return NO;
    }
    
    do
    {
        NSString *fieldAttribute = [self attribute:DTFieldAttribute atIndex:0 effectiveRange:&fieldRange];
        
        if ([fieldAttribute isEqualToString:DTListPrefixField])
        {
            [self deleteCharactersInRange:fieldRange];
            didDeletePrefix = YES;
        }
        
        fieldRange = [self rangeOfFieldAtIndex:0];
    }
    while (fieldRange.location != NSNotFound);
    
    return didDeletePrefix;
}

- (void)toggleParagraphSpacing:(BOOL)spaceOn atIndex:(NSUInteger)index spacing:(CGFloat)spacing
{
	[self beginEditing];
	
	NSString *string = [self string];
	
	NSRange paragraphRange = [string rangeOfParagraphAtIndex:index];
	
	NSLog(@"toggle %d in '%@'", spaceOn, [string substringWithRange:paragraphRange]);
	
	// need to restore appropriate paragraph spacing
	NSRange effectiveRange;
	
	CTParagraphStyleRef para = (__bridge CTParagraphStyleRef)[self attribute:(id)kCTParagraphStyleAttributeName atIndex:index effectiveRange:&effectiveRange];
	
	NSAssert(para!=nil, @"Empty Paragraph Style at index %lu", (unsigned long)index);
	
	// create our mutatable paragraph style
	DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:para];
	
    NSNumber *overriddenSpacingNum = [self attribute:DTParagraphSpacingOverriddenByListAttribute atIndex:paragraphRange.location effectiveRange:NULL];

    BOOL hasSpace = (paragraphStyle.paragraphSpacing>0) && !overriddenSpacingNum;
    
    if (hasSpace == spaceOn)
    {
        return;
    }
    
	if (spaceOn)
	{
        CGFloat spacing;
        if (overriddenSpacingNum)
        {
            spacing = [overriddenSpacingNum floatValue];
        }
        else
        {
            CTFontRef font = (__bridge CTFontRef)[self attribute:(id)kCTFontAttributeName atIndex:index effectiveRange:NULL];
            spacing = CTFontGetSize(font);
        }
            
		paragraphStyle.paragraphSpacing = spacing;
        
        [self removeAttribute:DTParagraphSpacingOverriddenByListAttribute range:paragraphRange];
	}
	else
	{
        // remember the previous paragraph spacing
        [self addAttribute:DTParagraphSpacingOverriddenByListAttribute value:[NSNumber numberWithFloat:paragraphStyle.paragraphSpacing] range:paragraphRange];
        
		paragraphStyle.paragraphSpacing = 0;
	}
	
	para = [paragraphStyle createCTParagraphStyle];
	
	[self addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)para range:paragraphRange];
	
	CFRelease(para);
	
	[self endEditing];
}

- (void)updateListStyle:(DTCSSListStyle *)listStyle inRange:(NSRange)range numberFrom:(NSInteger)nextItemNumber listIndent:(CGFloat)listIndent spacingAfterList:(CGFloat)spacingAfterList removeNonPrefixedParagraphsFromList:(BOOL)removeNonPrefixed
{
	[self beginEditing];
	
	// cannot set list style "None", instead remove it
	if (listStyle.type == DTCSSListStyleTypeNone)
	{
		listStyle = nil;
	}
	
	// extend range to include all paragraphs in their entirety
	range = [[self string] rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] init];
	
	// enumerate the paragraphs in this range
	NSString *string = [self string];
	
	__block NSInteger itemNumber = nextItemNumber;
	
	[string enumerateSubstringsInRange:range options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         BOOL isLastParagraph = NO;
         BOOL shouldAddList = (listStyle!=nil);
         
         if (NSMaxRange(enclosingRange)>=NSMaxRange(range))
         {
             isLastParagraph = YES;
         }
         
		 // get current attributes
		 NSDictionary *currentAttributes = [self attributesAtIndex:enclosingRange.location effectiveRange:NULL];
		 
		 DTCoreTextParagraphStyle *currentParagraphStyle = [currentAttributes paragraphStyle];
		 
		 NSMutableAttributedString *paragraphString = [[self attributedSubstringFromRange:enclosingRange] mutableCopy];
		 
		 // remove previous prefix in either case
         BOOL didDeletePrefix = [paragraphString deleteListPrefix];
         
         // if we want to remove non prefixed paragraphs and there was no prefix deleted
         if (removeNonPrefixed && !didDeletePrefix)
         {
             shouldAddList = NO;
         }
		 
		 // insert new prefix
		 if (shouldAddList)
		 {
             if (isLastParagraph)
             {
                 NSMutableDictionary *tmpDict = [currentAttributes mutableCopy];
                 [tmpDict updateParagraphSpacing:spacingAfterList];
                 currentAttributes = tmpDict;
             }
             else
             {
                 NSMutableDictionary *tmpDict = [currentAttributes mutableCopy];
                 [tmpDict updateParagraphSpacing:0];
                 currentAttributes = tmpDict;
             }
			 
			 CGFloat usedIndent = listIndent;
			 
			 if (!didDeletePrefix)
			 {
				 // add previous head indent
				 usedIndent += currentParagraphStyle.firstLineHeadIndent;
			 }
			 
			 NSAttributedString *prefixAttributedString = [NSAttributedString prefixForListItemWithCounter:itemNumber listStyle:listStyle listIndent:usedIndent attributes:currentAttributes];
			 
			 [paragraphString insertAttributedString:prefixAttributedString atIndex:0];
			 
			 // we also want the paragraph style to affect the entire paragraph
			 CTParagraphStyleRef tabPara = (__bridge CTParagraphStyleRef)[prefixAttributedString attribute:(id)kCTParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
			 
			 if (tabPara)
			 {
				 if (didDeletePrefix) // preserve previous indents
				 {
					 // preserve previous indents
					 DTCoreTextParagraphStyle *tabParagraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:tabPara];
					 
					 tabParagraphStyle.headIndent = currentParagraphStyle.headIndent;
					 tabParagraphStyle.firstLineHeadIndent = currentParagraphStyle.firstLineHeadIndent;
					 
					 CTParagraphStyleRef newPara = [tabParagraphStyle createCTParagraphStyle];
					 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)newPara range:NSMakeRange(0, [paragraphString length])];
					 CFRelease(newPara);
				 }
				 else
				 {
					 // was not prefixed before
					 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)tabPara range:NSMakeRange(0, [paragraphString length])];
				 }
			 }
			 else
			 {
				 NSLog(@"should not get here!!! No paragraph style!!!");
			 }
		 }
		 else
		 {
			 // need to restore appropriate paragraph spacing
			 CTParagraphStyleRef para = (__bridge CTParagraphStyleRef)[currentAttributes objectForKey:(id)kCTParagraphStyleAttributeName];
			 CTFontRef font = (__bridge CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
			 
			 if (para&&font)
			 {
				 DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:para];
				 paragraphStyle.paragraphSpacing = spacingAfterList;
				 paragraphStyle.headIndent = paragraphStyle.firstLineHeadIndent;
				 
				 para = [paragraphStyle createCTParagraphStyle];
				 
				 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)para range:NSMakeRange(0, [paragraphString length])];
			 }
			 else
			 {
				 NSLog(@"should not get here!!! No paragraph and no font style!!!");
			 }
		 }
		 
		 NSRange paragraphRange = NSMakeRange(0, [paragraphString length]);
		 
		 if (shouldAddList)
		 {
			 [paragraphString addAttribute:DTTextListsAttribute value:[NSArray arrayWithObject:listStyle] range:paragraphRange];
		 }
		 else
		 {
			 [paragraphString removeAttribute:DTTextListsAttribute range:paragraphRange];
		 }
		 
		 [tmpString appendAttributedString:paragraphString];
		 
		 
		 itemNumber++;
     }
     ];
	
	[self replaceCharactersInRange:range withAttributedString:tmpString];
	
	// first paragraph after toggled range
	NSInteger firstIndexInNextParagraph = range.location + [tmpString length];
	
	if (firstIndexInNextParagraph && firstIndexInNextParagraph < [self length])
	{
		DTCSSListStyle *followingList = [[self attribute:DTTextListsAttribute atIndex:firstIndexInNextParagraph effectiveRange:NULL] lastObject];
		
		if (!followingList)
		{
			[self toggleParagraphSpacing:YES atIndex:firstIndexInNextParagraph-1 spacing:spacingAfterList];
		}
	}
	
	[self endEditing];
}

- (void)correctParagraphSpacing
{
	NSString *string = [self string];
	
	NSRange range = NSMakeRange(0, [string length]);
	
	// extend to entire paragraphs
	range = [string rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	// enumerate paragraphs
	[string enumerateSubstringsInRange:range options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		
		BOOL isLastParagraph = (NSMaxRange(substringRange)==NSMaxRange(range));
		
		CTParagraphStyleRef para = (__bridge CTParagraphStyleRef)[self attribute:(id)kCTParagraphStyleAttributeName atIndex:substringRange.location effectiveRange:NULL];
		
		DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:para];
		
		NSArray *textLists = [self attribute:DTTextListsAttribute atIndex:substringRange.location effectiveRange:NULL];
		
		if (![textLists count]||isLastParagraph)
		{
			paragraphStyle.paragraphSpacing = 12.0;
		}
		else
		{
			paragraphStyle.paragraphSpacing = 0;
		}
		
		NSLog(@"space: %f", paragraphStyle.paragraphSpacing);
		
		para = [paragraphStyle createCTParagraphStyle];
		[self addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)para range:substringRange];
		CFRelease(para);
	}];
}

#pragma mark Marking
- (void)addMarkersForSelectionRange:(NSRange)range
{
    // avoid setting a margine into a prefix
    
    NSUInteger startPos = range.location;
    NSUInteger endPos = NSMaxRange(range);
    
    NSUInteger startOffset = 0;
    NSUInteger endOffset = 0;
    
    NSRange listPrefixRange = [self rangeOfFieldAtIndex:startPos];
    
    if (listPrefixRange.location != NSNotFound)
    {
        // need to shift marker to the right
        startPos = NSMaxRange(listPrefixRange);
    }
    
    listPrefixRange = [self rangeOfFieldAtIndex:endPos];
    
    if (listPrefixRange.location != NSNotFound)
    {
        endPos = NSMaxRange(listPrefixRange);
    }

    // need to shift end marker to the right
    if (endPos>=[self length])
    {
        endPos--;
        endOffset = 1;
    }
    
	// mark range
	[self addAttribute:DTSelectionMarkerAttribute value:[NSNumber numberWithInteger:startOffset] range:NSMakeRange(startPos, 1)];
	
	if (range.length)
	{
		[self addAttribute:DTSelectionMarkerAttribute value:[NSNumber numberWithInteger:endOffset] range:NSMakeRange(endPos, 1)];
	}
}

- (NSRange)markedRangeRemove:(BOOL)remove
{
	__block NSInteger index=0;
	
	__block NSInteger firstLocation = 0;
	__block NSInteger lastLocation = NSNotFound;
	
	[self enumerateAttribute:DTSelectionMarkerAttribute inRange:NSMakeRange(0, [self length]) options:0 usingBlock:^(NSNumber *value, NSRange range, BOOL *stop) {
		if (value)
		{
			switch (index)
			{
				case 0:
					firstLocation = range.location + [value integerValue];
					lastLocation = firstLocation;
					break;
				case 1:
					lastLocation = range.location + [value integerValue];
					*stop = YES;
					break;
			}
			
			if (remove)
			{
				[self removeAttribute:DTSelectionMarkerAttribute range:range];
			}
			
			index++;
		}
	}];
	
	return NSMakeRange(firstLocation, lastLocation-firstLocation);
}

@end
