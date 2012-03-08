//
//  DTRichTextEditorContentView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTAttributedTextContentView.h"



@interface DTRichTextEditorContentView : DTAttributedTextContentView
{
	BOOL _needsRemoveObsoleteAttachmentViews;
}

- (void)relayoutTextInRange:(NSRange)range;
- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text;

// removes attachments after next layout
@property (nonatomic) BOOL needsRemoveObsoleteAttachmentViews; 

@end
