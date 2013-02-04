//
//  DTHTMLAttributedStringBuilderTest.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 25.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DTHTMLAttributedStringBuilderTest.h"

#import "DTHTMLAttributedStringBuilder.h"
#import "DTCoreTextConstants.h"
#import "DTCoreTextParagraphStyle.h"
#import "DTTextAttachment.h"

@implementation DTHTMLAttributedStringBuilderTest

- (void)testSpaceBetweenUnderlines
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"SpaceBetweenUnderlines" ofType:@"html"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data options:nil documentAttributes:NULL];
	
	NSAttributedString *output = [builder generatedAttributedString];
	
	NSRange range_a;
	NSNumber *underLine = [output attribute:(id)kCTUnderlineStyleAttributeName atIndex:1 effectiveRange:&range_a];
	
	STAssertTrue([underLine integerValue]==0, @"Space between a and b should not be underlined");
}

// a block following an inline image should only cause a \n after the image, not whitespace
- (void)testWhitspaceAfterParagraphPromotedImage
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"WhitespaceFollowingImagePromotedToParagraph" ofType:@"html"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data options:nil documentAttributes:NULL];
	
	NSAttributedString *output = [builder generatedAttributedString];
	
	STAssertTrue([output length]==6, @"Generated String should be 6 characters");
	
	NSMutableString *expectedOutput = [NSMutableString stringWithFormat:@"1\n%@\n2\n", UNICODE_OBJECT_PLACEHOLDER];
	
	STAssertTrue([expectedOutput isEqualToString:[output string]], @"Expected output not matching");
}

// This should come out as Keep_me_together with the _ being non-breaking spaces
- (void)testKeepMeTogether
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"KeepMeTogether" ofType:@"html"];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	
	DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data options:nil documentAttributes:NULL];
	
	NSAttributedString *output = [builder generatedAttributedString];
	
	NSString *expectedOutput = @"Keep\u00a0me\u00a0together";
	
	STAssertTrue([expectedOutput isEqualToString:[output string]], @"Expected output not matching");
}

// tests functionality of dir attribute
- (void)testWritingDirection
{
	NSString *string = @"<p dir=\"rtl\">rtl</p><p dir=\"ltr\">ltr</p><p>normal</p>";
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data options:nil documentAttributes:NULL];
	
	NSAttributedString *output = [builder generatedAttributedString];
	
	CTParagraphStyleRef paragraphStyleRTL = (__bridge CTParagraphStyleRef)([output attribute:(id)kCTParagraphStyleAttributeName atIndex:0 effectiveRange:NULL]);
	DTCoreTextParagraphStyle *styleRTL = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paragraphStyleRTL];
	
	STAssertTrue(styleRTL.baseWritingDirection == NSWritingDirectionRightToLeft, @"Writing direction is not RTL");
	
	CTParagraphStyleRef paragraphStyleLTR = (__bridge CTParagraphStyleRef)([output attribute:(id)kCTParagraphStyleAttributeName atIndex:4 effectiveRange:NULL]);
	DTCoreTextParagraphStyle *styleLTR = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paragraphStyleLTR];
	
	STAssertTrue(styleLTR.baseWritingDirection == NSWritingDirectionLeftToRight, @"Writing direction is not LTR");

	CTParagraphStyleRef paragraphStyleNatural = (__bridge CTParagraphStyleRef)([output attribute:(id)kCTParagraphStyleAttributeName atIndex:8 effectiveRange:NULL]);
	DTCoreTextParagraphStyle *styleNatural = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paragraphStyleNatural];
	
	STAssertTrue(styleNatural.baseWritingDirection == NSWritingDirectionNatural, @"Writing direction is not Natural");
}

- (void)testAttachmentDisplaySize
{
	NSString *string = @"<img src=\"Oliver.jpg\" style=\"foo:bar\">";
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:data options:nil documentAttributes:NULL];
	
	NSAttributedString *output = [builder generatedAttributedString];
	
	STAssertEquals([output length],(NSUInteger)1 , @"Output length should be 1");

	DTTextAttachment *attachment = [output attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:NULL];
	
	STAssertNotNil(attachment, @"No attachment found in output");
	
	CGSize expectedSize = CGSizeMake(300, 300);
	STAssertEquals(attachment.originalSize, expectedSize, @"Expected displaySize to be 300x300");
	STAssertEquals(attachment.displaySize, expectedSize, @"Expected displaySize to be 300x300");
}


@end
