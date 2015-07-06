//
//  DTRichTextEditorView+Attributes.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/3/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView+Attributes.h"
#import <DTCoreText/NSAttributedString+HTML.h>
#import <DTCoreText/NSMutableAttributedString+HTML.h>

#import "DTTextPosition.h"
#import "DTTextRange.h"

@implementation DTRichTextEditorView (Attributes)

#pragma mark - Querying Custom HTML Attributes

- (NSDictionary *)HTMLAttributesAtPosition:(UITextPosition *)position
{
	NSUInteger index = [(DTTextPosition *)position location];
	
	return [self.attributedTextContentView.layoutFrame.attributedStringFragment HTMLAttributesAtIndex:index];
}

- (NSRange)rangeOfHTMLAttribute:(NSString *)name atPosition:(UITextPosition *)position
{
	NSUInteger index = [(DTTextPosition *)position location];

	return [self.attributedTextContentView.layoutFrame.attributedStringFragment rangeOfHTMLAttribute:name atIndex:index];
}


#pragma mark - Modifying Custom HTML Attributes

- (void)addHTMLAttribute:(NSString *)name value:(id)value range:(UITextRange *)range replaceExisting:(BOOL)replaceExisting
{
	NSRange nsRange = [(DTTextRange *)range NSRangeValue];
	
	[(NSMutableAttributedString *)self.attributedTextContentView.layoutFrame.attributedStringFragment addHTMLAttribute:name value:value range:nsRange replaceExisting:replaceExisting];
}

- (void)removeHTMLAttribute:(NSString *)name range:(UITextRange *)range
{
	NSRange nsRange = [(DTTextRange *)range NSRangeValue];
	
	[(NSMutableAttributedString *)self.attributedTextContentView.layoutFrame.attributedStringFragment removeHTMLAttribute:name range:nsRange];
}

@end
