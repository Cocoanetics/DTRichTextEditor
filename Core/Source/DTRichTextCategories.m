//
//  DTRichTextCategories.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTRichTextCategories.h"

@implementation DTCoreTextGlyphRun (DTRichText)

- (void)adjustStringRangeToStartAtIndex:(NSInteger)index
{
	NSRange range = [self stringRange];
	range.location = index;
	
	_stringRange = range;
}

@end


@implementation DTCoreTextLayoutLine (DTRichText)

- (void)adjustStringRangeToStartAtIndex:(NSInteger)index;
{
	NSRange range = [self stringRange];
	NSInteger offset = index - range.location;
	_stringLocationOffset += offset;
	
	// also need to correct the string ranges of the glyph runs
	for (id oneRun in self.glyphRuns)
	{
		[oneRun adjustStringRangeToStartAtIndex:index];
		index += [oneRun stringRange].length;
	}
}

@end