//
//  DTRichTextEditorView+DTCoreText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView+DTCoreText.h"

@implementation DTRichTextEditorView (DTCoreText)

- (NSUInteger)numberOfLayoutLines
{
	return [self.contentView.layoutFrame.lines count];
}

- (DTCoreTextLayoutLine *)layoutLineAtIndex:(NSUInteger)lineIndex
{
	return [self.contentView.layoutFrame.lines objectAtIndex:lineIndex];
}

- (DTCoreTextLayoutLine *)layoutLineContainingTextPosition:(DTTextPosition *)textPosition
{
	// get index
	NSUInteger index = textPosition.location;
	
	// get line from layout frame
	return [self.contentView.layoutFrame lineContainingIndex:index];
}

- (NSArray *)visibleLayoutLines
{
	CGRect visibleRect = self.bounds;
	
	return [self.contentView.layoutFrame linesVisibleInRect:visibleRect];
}

@end
