//
//  DTRichTextEditorView+DTCoreText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"

/**
 The **DTCore Text Category** features enhancements for DTRichTextEditorView to interact with DTCoreText internal information.
 */
@interface DTRichTextEditorView (DTCoreText)

/**
 @returns The number of text lines in the receiver.
 */
- (NSUInteger)numberOfLayoutLines;

/**
 Returns the layout line at the given string index
 @param lineIndex The index of the line
 @returns the layout line
 */
- (DTCoreTextLayoutLine *)layoutLineAtIndex:(NSUInteger)lineIndex;

/**
 Returns the layout line that contains the given text position.
 @param textPosition The text position
 @returns the layout line
 */
- (DTCoreTextLayoutLine *)layoutLineContainingTextPosition:(UITextPosition *)textPosition;

/**
 @returns An array of layout lines that is currently visible in the receiver.
 */
- (NSArray *)visibleLayoutLines;

@end
