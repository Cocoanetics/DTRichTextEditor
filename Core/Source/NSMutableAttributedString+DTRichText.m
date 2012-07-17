//
//  NSMutableAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSMutableDictionary+DTRichText.h"

#import "DTTextAttachment.h"
#import <CoreText/CoreText.h>
#import "NSAttributedStringRunDelegates.h"
#import "NSString+HTML.h"

#import "DTCoreTextFontDescriptor.h"
#import "DTCoreTextParagraphStyle.h"
#import "DTCoreTextConstants.h"

#import <CoreText/CoreText.h>


NSString *DTSelectionMarkerAttribute = @"DTSelectionMarker";

@implementation NSMutableAttributedString (DTRichText)

- (NSUInteger)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	[self beginEditing];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
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
			[attrs setObject:(id)[color CGColor] forKey:DTBackgroundColorAttribute];
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
		[self addAttribute:DTGUIDAttribute value:[NSString guid] range:range];
	}
	
	[self endEditing];
}

- (void)adjustTextAlignment:(CTTextAlignment)alignment inRange:(NSRange)range
{
	[self beginEditing];
	
	[self enumerateAttribute:(id)kCTParagraphStyleAttributeName inRange:range options:0
				  usingBlock:^(id value, NSRange range, BOOL *stop) {
					  CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)value;
					  
					  DTCoreTextParagraphStyle *para = [[DTCoreTextParagraphStyle alloc] initWithCTParagraphStyle:paragraphStyle];
					  para.alignment = alignment;
					  
					  CTParagraphStyleRef newParagraphStyle = [para createCTParagraphStyle];
					  [self addAttribute:(id)kCTParagraphStyleAttributeName value:CFBridgingRelease(newParagraphStyle) range:range];
				  }];
	
	[self endEditing];
}

- (void)extendPreviousList:(DTCSSListStyle *)listStyle toIncludeRange:(NSRange)range numberingFrom:(NSInteger)nextItemNumber
{
	[self beginEditing];
	
	// extend range to include all paragraphs in their entirety
	range = [[self string] rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	// check if there is a list on the paragraph before, then we want to extend this
	DTCSSListStyle *listBefore = nil;
	
	if (range.location>0)
	{
		NSArray *lists = [self attribute:DTTextListsAttribute atIndex:range.location effectiveRange:NULL];
		
		listBefore = [lists lastObject];
	}
	
	
	NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] init];
	
	// enumerate the paragraphs in this range
	NSString *string = [self string];
	
	__block NSInteger itemNumber = nextItemNumber;
	
	NSUInteger length = [string length];
	
	[string enumerateSubstringsInRange:range options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
		 BOOL hasParagraphEnd = NO;
		 
		 // extend range to include \n
		 if (NSMaxRange(substringRange) < length)
		 {
			 substringRange.length ++;
			 hasParagraphEnd = YES;
		 }
		 
		 // get current attributes
		 NSDictionary *currentAttributes = [self attributesAtIndex:substringRange.location effectiveRange:NULL];
		 
		 NSArray *currentLists = [currentAttributes objectForKey:DTTextListsAttribute];
		 
		 BOOL setNewLists = NO;
		 
		 NSMutableAttributedString *paragraphString = [[self attributedSubstringFromRange:substringRange] mutableCopy];
		 
		 
		 DTCSSListStyle *effectiveListStyle = [currentLists lastObject];
		 
		 if (effectiveListStyle)
		 {
			 // there is a list, if it is different, update
			 if (effectiveListStyle.type != listStyle.type)
			 {
				 setNewLists = YES;
			 }
			 else
			 {
				 // toggle list off
				 setNewLists = NO;
			 }
		 }
		 else
		 {
			 setNewLists = YES;
		 }
		 
		 // remove previous prefix in either case
		 if (effectiveListStyle)
		 {
			 NSString *prefix = [effectiveListStyle prefixWithCounter:itemNumber];
			 
			 [paragraphString deleteCharactersInRange:NSMakeRange(0, [prefix length])];
		 }
		 
		 // insert new prefix
		 NSAttributedString *prefixAttributedString = [NSAttributedString prefixForListItemWithCounter:itemNumber listStyle:listStyle listIndent:20.0 attributes:currentAttributes];
		 
		 [paragraphString insertAttributedString:prefixAttributedString atIndex:0];
		 
		 // we also want the paragraph style to affect the entire paragraph
		 CTParagraphStyleRef tabPara = (__bridge CTParagraphStyleRef)[prefixAttributedString attribute:(id)kCTParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
		 
		 if (tabPara)
		 {
			 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)tabPara range:NSMakeRange(0, [paragraphString length])];
		 }
		 else
		 {
			 NSLog(@"should not get here!!! No paragraph style!!!");
		 }
		 
		 
		 NSRange paragraphRange = NSMakeRange(0, [paragraphString length]);
		 
		 [paragraphString addAttribute:DTTextListsAttribute value:[NSArray arrayWithObject:listStyle] range:paragraphRange]; 
		 
		 [tmpString appendAttributedString:paragraphString];
		 
		 itemNumber++;
     }
     ];
	
	[self replaceCharactersInRange:range withAttributedString:tmpString];
	
	[self endEditing];
}


- (void)toggleParagraphSpacing:(BOOL)spaceOn atIndex:(NSUInteger)index
{
	[self beginEditing];
	
	NSString *string = [self string];
	
	NSRange paragraphRange = [string rangeOfParagraphAtIndex:index];
	
	NSLog(@"toggle %d in '%@'", spaceOn, [string substringWithRange:paragraphRange]);
	
	// need to restore appropriate paragraph spacing
	NSRange effectiveRange;
	
	CTParagraphStyleRef para = (__bridge CTParagraphStyleRef)[self attribute:(id)kCTParagraphStyleAttributeName atIndex:index effectiveRange:&effectiveRange];
	
	NSAssert(para!=nil, @"Empty Paragraph Style at index %d", index);
	
	// create our mutatable paragraph style
	DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:para];
	
	if (spaceOn)
	{
		CTFontRef font = (__bridge CTFontRef)[self attribute:(id)kCTFontAttributeName atIndex:index effectiveRange:NULL];
		CGFloat fontSize = CTFontGetSize(font);
		paragraphStyle.paragraphSpacing = fontSize;
	}
	else
	{
		paragraphStyle.paragraphSpacing = 0;
	}
	
	para = [paragraphStyle createCTParagraphStyle];
	
	[self addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)para range:paragraphRange];
	
	CFRelease(para);
	
	[self endEditing];
}

- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(NSRange)range numberFrom:(NSInteger)nextItemNumber
{
	[self beginEditing];
	
	// extend range to include all paragraphs in their entirety
	range = [[self string] rangeOfParagraphsContainingRange:range parBegIndex:NULL parEndIndex:NULL];
	
	NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] init];
	
	// enumerate the paragraphs in this range
	NSString *string = [self string];
	
	__block NSInteger itemNumber = nextItemNumber;
	NSUInteger length = [string length];
	
	[string enumerateSubstringsInRange:range options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
		 BOOL hasParagraphEnd = NO;
		 
		 // extend range to include \n
		 if (NSMaxRange(substringRange) < length)
		 {
			 substringRange.length ++;
			 hasParagraphEnd = YES;
		 }
		 
		 // get current attributes
		 NSDictionary *currentAttributes = [self attributesAtIndex:substringRange.location effectiveRange:NULL];
		 
		 NSArray *currentLists = [currentAttributes objectForKey:DTTextListsAttribute];
		 
		 BOOL setNewLists = NO;
		 
		 NSMutableAttributedString *paragraphString = [[self attributedSubstringFromRange:substringRange] mutableCopy];
		 
		 
		 DTCSSListStyle *effectiveListStyle = [currentLists lastObject];
		 
		 if (effectiveListStyle)
		 {
			 // there is a list, if it is different, update
			 if (effectiveListStyle.type != listStyle.type)
			 {
				 setNewLists = YES;
			 }
			 else
			 {
				 // toggle list off
				 setNewLists = NO;
			 }
		 }
		 else
		 {
			 setNewLists = YES;
		 }
		 
		 if (!listStyle)
		 {
			 setNewLists = NO;
		 }
		 
		 // remove previous prefix in either case
		 if (effectiveListStyle)
		 {
			 NSString *prefix = [effectiveListStyle prefixWithCounter:itemNumber];
			 
			 [paragraphString deleteCharactersInRange:NSMakeRange(0, [prefix length])];
		 }
		 
		 // insert new prefix
		 if (setNewLists)
		 {
			 NSAttributedString *prefixAttributedString = [NSAttributedString prefixForListItemWithCounter:itemNumber listStyle:listStyle listIndent:20 attributes:currentAttributes];
			 
			 [paragraphString insertAttributedString:prefixAttributedString atIndex:0];
			 
			 // we also want the paragraph style to affect the entire paragraph
			 CTParagraphStyleRef tabPara = (__bridge CTParagraphStyleRef)[prefixAttributedString attribute:(id)kCTParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
			 
			 if (tabPara)
			 {
				 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)tabPara range:NSMakeRange(0, [paragraphString length])];
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
				 
				 CGFloat fontSize = CTFontGetSize(font);
				 paragraphStyle.paragraphSpacing = fontSize;
				 
				 para = [paragraphStyle createCTParagraphStyle];
				 
				 [paragraphString addAttribute:(id)kCTParagraphStyleAttributeName  value:(__bridge id)para range:NSMakeRange(0, [paragraphString length])];
			 }
			 else
			 {
				 NSLog(@"should not get here!!! No paragraph and no font style!!!"); 
			 }
		 }
		 
		 NSRange paragraphRange = NSMakeRange(0, [paragraphString length]);
		 
		 if (setNewLists)
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
			[self toggleParagraphSpacing:YES atIndex:firstIndexInNextParagraph-1];
		}
	}
	
	[self endEditing];
}

- (void)correctParagraphSpacingForRange:(NSRange)range
{
	NSString *string = [self string];
	
	range = NSMakeRange(0, [string length]);
	
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
	// mark range
	[self addAttribute:DTSelectionMarkerAttribute value:[NSNumber numberWithBool:YES] range:NSMakeRange(range.location, 1)];
	
	if (range.length)
	{
		[self addAttribute:DTSelectionMarkerAttribute value:[NSNumber numberWithBool:YES] range:NSMakeRange(range.location + range.length - 1, 1)];
	}
}

- (NSRange)markedRangeRemove:(BOOL)remove
{
	__block NSInteger index=0;
	
	__block NSInteger firstLocation = 0;
	__block NSInteger lastLocation = NSNotFound;
	
	[self enumerateAttribute:DTSelectionMarkerAttribute inRange:NSMakeRange(0, [self length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value)
		{
			switch (index) 
			{
				case 0:
					firstLocation = range.location;
					lastLocation = firstLocation;
					break;
				case 1:
					lastLocation = range.location;
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
	
	return NSMakeRange(firstLocation, lastLocation-firstLocation+1);
}

@end
