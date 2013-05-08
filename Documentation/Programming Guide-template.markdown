DTRichTextEditor Programming Guide
==================================

This document tries to answer the kinds of questions a programmer might ask working with DTRichTextEditor and provide examples for common use cases.

Getting Typing Attributes
-------------------------

The typing attributes of a text range are the attributes that text gets that is newly inserted to replace the current selection. Since a selection can also be zero length (aka caret) there must also be a place for the editor to store those attributes until the user begins to time test. 

The common pattern is to first check the overrideInsertionAttributes property and if this is not set, then query the editor for the typing attributes for the selection range:

    UITextRange *range = editor.selectedTextRange;

    NSDictionary *typingAttributes = editor.overrideInsertionAttributes;

    if (!typingAttributes)
    {
       typingAttributes = [editor typingAttributesForRange:range];
    }
	
	
Setting Paragraph Spacing
-------------------------

Due to the various kinds of paragraph styles there can be in rich text it is not possible to set a single paragraph spacing. Instead you specify the paragraph spacing for each paragraph style with a modifier stylesheet which you set as part of the textDefaults. Those defaults are used when parsing HTML.

    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	DTCSSStylesheet *styleSheet = [[DTCSSStylesheet alloc] initWithStyleBlock:@"p {margin-bottom:2.5em} ol {margin-bottom:2.5em} li {margin-bottom:2.5em}"];
    [defaults setObject:styleSheet forKey:DTDefaultStyleSheet];
	[editor setTextDefaults:defaults];
	
Typically you would set the bottom margin for the paragraph styles: P, OL, UL, H1-H6. These styles are combined with the default.css stylesheet found in DTCoreText.


Right to Left Text
------------------

Glyphs in glyph runs can be ordered left-to-right or right-to-left. You can determine which via the writingDirectionIsRightToLeft property of DTCoreTextGlyphRun.

    UITextRange *range = editor.selectedTextRange;
    DTCoreTextGlyphRun *run = [editor glyphRunAtPosition:[range start]];
    
    BOOL rtl = run.writingDirectionIsRightToLeft;