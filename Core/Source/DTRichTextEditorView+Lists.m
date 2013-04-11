//
//  DTRichTextEditorView+Lists.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"

@interface DTRichTextEditorView (private)

- (void)updateCursorAnimated:(BOOL)animated;
- (void)hideContextMenu;
- (void)_closeTypingUndoGroupIfNecessary;

@property (nonatomic, retain) NSDictionary *overrideInsertionAttributes;

@end

/**
 The **Lists** category enhances DTRichTextEditorView with support for Lists and their manipulation.
 */
@implementation DTRichTextEditorView (Lists)

- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];
    
    // extend range to full paragraphs
    UITextRange *fullParagraphsRange = (DTTextRange *)[self textRangeOfParagraphsContainingRange:range];
    
    // get the mutable text for this range
    NSMutableAttributedString *mutableText = [[self attributedSubstringForRange:fullParagraphsRange] mutableCopy];
    
    // remember the current selection in the mutableText
    NSRange tmpRange = [(DTTextRange *)self.selectedTextRange NSRangeValue];
    tmpRange.location -= [(DTTextPosition *)fullParagraphsRange.start location];
    [mutableText addMarkersForSelectionRange:tmpRange];
    
    // check if we are extending a list in the paragraph before this one
    DTCSSListStyle *extendingList = nil;
	NSInteger nextItemNumber = [listStyle startingItemNumber];
    
    // we also need to adjust the paragraph spacing of the previous paragraph
    UITextRange *rangeOfPreviousParagraph = nil;
    NSMutableAttributedString *mutablePreviousParagraph = nil;
    
    // and the following paragraph is necessary to know if we need paragraph spacing
    DTCSSListStyle *followingList = nil;
    
    NSMutableAttributedString *entireAttributedString = (NSMutableAttributedString *)self.attributedText;
    
    // if there is text before the toggled paragraphs
    if ([self comparePosition:[self beginningOfDocument] toPosition:[fullParagraphsRange start]] == NSOrderedAscending)
    {
        DTTextPosition *positionBefore = (DTTextPosition *)[self positionFromPosition:[fullParagraphsRange start] offset:-1];
        NSUInteger pos = [positionBefore location];
        
        // get previous paragraph
        rangeOfPreviousParagraph = [self textRangeOfParagraphContainingPosition:positionBefore];
        mutablePreviousParagraph = [[self attributedSubstringForRange:rangeOfPreviousParagraph] mutableCopy];
        
        DTCSSListStyle *effectiveList = [[entireAttributedString attribute:DTTextListsAttribute atIndex:pos effectiveRange:NULL] lastObject];
        
        if (effectiveList.type == listStyle.type)
        {
            extendingList = effectiveList;
        }
        
        if (extendingList)
        {
            nextItemNumber = [entireAttributedString itemNumberInTextList:extendingList atIndex:pos]+1;
        }
    }
    
    // get list style following toggled paragraphs
    if ([self comparePosition:[self endOfDocument] toPosition:[fullParagraphsRange end]] == NSOrderedDescending)
    {
        NSUInteger index = [(DTTextPosition *)[fullParagraphsRange end] location]+1;
        
        followingList = [[entireAttributedString attribute:DTTextListsAttribute atIndex:index effectiveRange:NULL] lastObject];
    }
    
    
    // toggle the list style in this mutable text
    NSRange entireMutableRange = NSMakeRange(0, [mutableText length]);
    [mutableText toggleListStyle:listStyle inRange:entireMutableRange numberFrom:nextItemNumber];
    
    // check if this became a list item
    DTCSSListStyle *effectiveList = [[mutableText attribute:DTTextListsAttribute atIndex:0 effectiveRange:NULL] lastObject];
    
    if (extendingList && effectiveList)
    {
        [mutablePreviousParagraph toggleParagraphSpacing:NO atIndex:mutablePreviousParagraph.length-1];
    }
    else
    {
        [mutablePreviousParagraph toggleParagraphSpacing:YES atIndex:mutablePreviousParagraph.length-1];
    }
    
    if (followingList && effectiveList)
    {
        [mutableText toggleParagraphSpacing:NO atIndex:mutableText.length-1];
    }
    else
    {
        [mutableText toggleParagraphSpacing:YES atIndex:mutableText.length-1];
    }
    
    // get modified selection range and remove marking from substitution string
    NSRange rangeToSelectAfterwards = [mutableText markedRangeRemove:YES];
    rangeToSelectAfterwards.location += [(DTTextPosition *)fullParagraphsRange.start location];
    
    if (mutablePreviousParagraph)
    {
        // append this before the mutableText
        [mutableText insertAttributedString:mutablePreviousParagraph atIndex:0];
        
        // adjust the range to be replaced
        fullParagraphsRange = [self textRangeFromPosition:[rangeOfPreviousParagraph start] toPosition:[fullParagraphsRange end]];
    }
    
    // substitute
    [self.inputDelegate textWillChange:self];
    [self replaceRange:fullParagraphsRange withText:mutableText];
    [self.inputDelegate textDidChange:self];
    
    // restore selection
    [self.inputDelegate selectionWillChange:self];
    self.selectedTextRange = [DTTextRange rangeWithNSRange:rangeToSelectAfterwards];
    [self.inputDelegate selectionDidChange:self];
    
	// attachment positions might have changed
	[self.attributedTextContentView layoutSubviewsInRect:self.bounds];
	
	// cursor positions might have changed
	[self updateCursorAnimated:NO];
	
	[self hideContextMenu];
}

@end
