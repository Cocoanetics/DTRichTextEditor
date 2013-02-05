//
//  DTMutableCoreTextLayoutFrame.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/23/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTCoreTextLayoutFrame.h"

@interface DTMutableCoreTextLayoutFrame : DTCoreTextLayoutFrame
{
	UIEdgeInsets _edgeInsets; // space between frame edges and text
    BOOL shouldRebuildLines;
}

@property (nonatomic, assign) BOOL shouldRebuildLines;

// default initializer
- (id)initWithFrame:(CGRect)frame attributedString:(NSAttributedString *)attributedString;

- (void)relayoutText;

// replace the entire current string
- (void)setAttributedString:(NSAttributedString *)attributedString;

// incremental layouting
- (void)relayoutTextInRange:(NSRange)range;

- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text dirtyRect:(CGRect *)dirtyRect;

- (void)setFrame:(CGRect)frame;


@end
