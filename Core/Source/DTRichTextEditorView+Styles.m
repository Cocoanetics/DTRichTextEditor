//
//  DTRichTextEditorView+Styles.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 16.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView+Styles.h"


@implementation DTRichTextEditorView (Styles)

- (NSDictionary *)_attributesForHTMLStringUsingTextDefaults:(NSString *)HTMLString
{
    NSData *data = [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:data options:[self textDefaults] documentAttributes:NULL];
	
	return [attributedString attributesAtIndex:0 effectiveRange:NULL];
}

- (NSDictionary *)attributesForTagName:(NSString *)tagName tagClass:(NSString *)tagClass tagIdentifier:(NSString *)tagIdentifier relativeToTextSize:(CGFloat)textSize
{
	NSParameterAssert(tagName);
    
    NSMutableString *html = [NSMutableString stringWithFormat:@"<span style=\"font-size:%.0fpx\"><%@", textSize, tagName];
    
    if (tagClass)
    {
        [html appendFormat:@" class=\"%@\"", tagClass];
    }
    
    if (tagIdentifier)
    {
        [html appendFormat:@" id=\"%@\"", tagIdentifier];
    }
    
    [html appendFormat:@">A</%@></span>", tagName];
    
    return [self _attributesForHTMLStringUsingTextDefaults:html];
}

- (NSDictionary *)attributedStringAttributesForTextDefaults
{
    return [self _attributesForHTMLStringUsingTextDefaults:@"<p />"];
}

- (CGFloat)listIndentForListStyle:(DTCSSListStyle *)listStyle
{
    if (!listStyle)
    {
        return 0;
    }
    
    NSString *html;
    
    if ([listStyle isOrdered])
    {
        html = @"<ol><li>A</li></ol>";
    }
    else
    {
        html = @"<ul><li>A</li></ul>";
    }
    
    NSDictionary *attributes = [self _attributesForHTMLStringUsingTextDefaults:html];
    
    // TODO: also support NSParagraphStyle
    
    CTParagraphStyleRef p = (__bridge CTParagraphStyleRef)([attributes objectForKey:(id)kCTParagraphStyleAttributeName]);
    
    DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:p];
    
    return paragraphStyle.headIndent;
}

- (DTCoreTextParagraphStyle *)paragraphStyleForTagName:(NSString *)tagName tagClass:(NSString *)tagClass tagIdentifier:(NSString *)tagIdentifier relativeToTextSize:(CGFloat)textSize
{
    NSDictionary *attributes = [self attributesForTagName:tagName tagClass:tagClass tagIdentifier:tagIdentifier relativeToTextSize:textSize];
    
    CTParagraphStyleRef ctParagraphStyle = (__bridge CTParagraphStyleRef)([attributes objectForKey:(id)kCTParagraphStyleAttributeName]);
	
	if (ctParagraphStyle)
	{
		return [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:ctParagraphStyle];
	}
	
	// try NSParagraphStyle
	
	if (![NSParagraphStyle class])
	{
		// unknown class
		return nil;
	}
	
	NSParagraphStyle *nsParagraphStyle = [attributes objectForKey:NSParagraphStyleAttributeName];
	return [DTCoreTextParagraphStyle paragraphStyleWithNSParagraphStyle:nsParagraphStyle];
}

@end
