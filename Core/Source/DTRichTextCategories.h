//
//  DTRichTextCategories.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTCoreTextGlyphRun.h"
#import "DTCoreTextLayoutLine.h"

@interface DTCoreTextGlyphRun (DTRichText)

// needed because due to incremental merging the string indices might change
- (void)adjustStringRangeToStartAtIndex:(NSInteger)index;

@end


@interface DTCoreTextLayoutLine (DTRichText)

// needed because due to incremental merging the string indices might change
- (void)adjustStringRangeToStartAtIndex:(NSInteger)index;

@end
