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
