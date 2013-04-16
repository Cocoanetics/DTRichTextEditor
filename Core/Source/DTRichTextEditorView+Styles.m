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

- (DTCoreTextParagraphStyle *)paragraphStyleForTagName:(NSString *)tagName tagClass:(NSString *)tagClass tagIdentifier:(NSString *)tagIdentifier
{
    NSParameterAssert(tagName);
    
    NSMutableString *html = [NSMutableString stringWithFormat:@"<%@", tagName];
    
    if (tagClass)
    {
        [html appendFormat:@" class=\"%@\"", tagClass];
    }
    
    if (tagIdentifier)
    {
        [html appendFormat:@" id=\"%@\"", tagIdentifier];
    }
    
    [html appendFormat:@">A</%@>", tagName];
    
    NSDictionary *attributes = [self _attributesForHTMLStringUsingTextDefaults:html];
    
    // TODO: also support NSParagraphStyle
    
    CTParagraphStyleRef p = (__bridge CTParagraphStyleRef)([attributes objectForKey:(id)kCTParagraphStyleAttributeName]);
    
    return [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:p];
}

@end
