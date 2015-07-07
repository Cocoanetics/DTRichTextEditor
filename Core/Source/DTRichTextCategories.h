//
//  DTRichTextCategories.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreTextGlyphRun.h>
#import <DTCoreText/DTCoreTextLayoutLine.h>

/**
 Editor-related extensions to <DTCoreTextGlyphRun>
 */
@interface DTCoreTextGlyphRun (DTRichText)

/** 
 Modifies the internal string range to begin at a given index
 
 This is needed because due to incremental merging the string indices might change
 @param index The new starting string index to set
 */
- (void)adjustStringRangeToStartAtIndex:(NSInteger)index;

@end

/**
 Editor-related extensions to <DTCoreTextLayoutLine>
 */
@interface DTCoreTextLayoutLine (DTRichText)

/**
 Modifies the internal string range to begin at a given index
 
 This is needed because due to incremental merging the string indices might change
 @param index The new starting string index to set
 */
- (void)adjustStringRangeToStartAtIndex:(NSInteger)index;

@end
