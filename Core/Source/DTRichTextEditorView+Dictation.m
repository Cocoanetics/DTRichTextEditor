//
//  DTRichTextEditorView+Dictation.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"

@interface DTRichTextEditorView (private)

@property (nonatomic, retain) DTTextSelectionView *selectionView;
@property (nonatomic, assign) BOOL waitingForDictionationResult;
@property (nonatomic, retain) DTDictationPlaceholderView *dictationPlaceholderView;

@end

@implementation DTRichTextEditorView (Dictation)

- (void)dictationRecordingDidEnd
{
	// make a placeholder attachment, will be creating a placeholderView at run time
	DTDictationPlaceholderTextAttachment *attachment = [[DTDictationPlaceholderTextAttachment alloc] init];
    
	[self replaceRange:[self selectedTextRange] withAttachment:attachment inParagraph:NO];
    
    // this hides the selection until replaceRange:withText: inserts the result
    self.waitingForDictionationResult = YES;
}

- (UITextRange *)textRangeOfDictationPlaceholder
{
    __block NSRange foundRange = NSMakeRange(0, 0);
    
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, [self.attributedText length]) options:0 usingBlock:^(DTTextAttachment *value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[DTDictationPlaceholderTextAttachment class]])
        {
            foundRange = range;
            *stop = YES;
        }
    }];
    
    if (!foundRange.length)
    {
        return nil;
    }
    
    return [DTTextRange rangeWithNSRange:foundRange];
}

@end
