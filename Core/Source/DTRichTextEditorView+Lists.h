//
//  DTRichTextEditorView+Lists.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorView.h"

@interface DTRichTextEditorView (Lists)

/**
 Toggles a list style on a given range.
 
 Toggling the list style is its own Undo group unless you set _keepCurrentUndoGroup to `YES`.
 @param listStyle the list style to toggle, or `nil` to remove the list style.
 @param range The text range
 */
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range;

/**
 Handles the following scenarios of entering a New Line character inside a list block.
 
 - NL at beginning of an empty paragraph at end of list: toggles off the list for this paragraph
 - NL at end of non-empty paragraph: extends the list to the new paragraph
 - NL in some other paragraph of the list: inserts a new list paragraph inside the list
 
 @param range The text range of the selection
 @returns `YES` if the range started inside a list
 */
- (BOOL)handleNewLineInputInListInRange:(UITextRange *)range;


/**
 Updates lists (prefixes and spacing) intersecting with the given range
 @param range The text range to update
 @param removeNonPrefixed Whether lines that don't posess a prefix should be removed from lists
 */
- (void)updateListsInRange:(UITextRange *)range removeNonPrefixedLinesFromLists:(BOOL)removeNonPrefixed;

@end
