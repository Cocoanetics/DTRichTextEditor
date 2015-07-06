//
//  DTRichTextEditorView+DTCoreText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView+DTCoreText.h"
#import <DTCoreText/DTCoreText.h>

@implementation DTRichTextEditorView (DTCoreText)

- (NSUInteger)numberOfLayoutLines
{
	return [self.attributedTextContentView.layoutFrame.lines count];
}

- (DTCoreTextLayoutLine *)layoutLineAtIndex:(NSUInteger)lineIndex
{
	return [self.attributedTextContentView.layoutFrame.lines objectAtIndex:lineIndex];
}

- (DTCoreTextLayoutLine *)layoutLineContainingTextPosition:(UITextPosition *)textPosition
{
	// get index
	NSUInteger index = [(DTTextPosition *)textPosition location];
	
	// get line from layout frame
	return [self.attributedTextContentView.layoutFrame lineContainingIndex:index];
}

- (NSArray *)visibleLayoutLines
{
	CGRect visibleRect = self.bounds;
	
	return [self.attributedTextContentView.layoutFrame linesVisibleInRect:visibleRect];
}

@end
