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
    
    NSAttributedString *attributedText = self.attributedText;

    // get the full paragraph range of our selection
    NSRange selectionRange = [(DTTextRange *)range NSRangeValue];
    NSRange paragraphRange = [attributedText.string rangeOfParagraphsContainingRange:selectionRange parBegIndex:NULL parEndIndex:NULL];

    // check if there is a list at this index
    NSUInteger index = [(DTTextPosition *)[range start] location];
    DTCSSListStyle *listAroundSelection = [[attributedText attribute:DTTextListsAttribute atIndex:index effectiveRange:NULL] lastObject];
    DTCSSListStyle *listBeforeSelection = nil;
    DTCSSListStyle *listAfterSelection = nil;
    
    NSRange totalRange = paragraphRange; // range of the entire attributed string to modify
    
    if (listAroundSelection)
    {
        // find extent of this list
        NSRange listRange = [attributedText rangeOfTextList:listAroundSelection atIndex:index];
        
        // join up all ranges, this is the range we want to modify in the end
        totalRange = NSUnionRange(listRange, paragraphRange);
        
        if (listAroundSelection.type == listStyle.type)
        {
            // remove list (= toggle)
            listStyle = nil;
        }
    }
    else
    {
        // check if extending a list on the paragraph before the selection
        if (paragraphRange.location > 0)
        {
            listBeforeSelection = [[attributedText attribute:DTTextListsAttribute atIndex:paragraphRange.location-1 effectiveRange:NULL] lastObject];
            
            // if same type we extend the list
            if (listBeforeSelection.type == listStyle.type)
            {
                // find extent of this list
                NSRange listRange = [attributedText rangeOfTextList:listBeforeSelection atIndex:paragraphRange.location-1];
                
                // join up all ranges, this is the range we want to modify in the end
                totalRange = NSUnionRange(listRange, totalRange);
            }
        }

        // check if extending a list on the paragraph after the selection
        if (NSMaxRange(paragraphRange) < attributedText.length)
        {
            listAfterSelection = [[attributedText attribute:DTTextListsAttribute atIndex:NSMaxRange(paragraphRange) effectiveRange:NULL] lastObject];
            
            // if same type we extend the list
            if (listAfterSelection.type == listStyle.type)
            {
                // find extent of this list
                NSRange listRange = [attributedText rangeOfTextList:listAfterSelection atIndex:NSMaxRange(paragraphRange)];
                
                // join up all ranges, this is the range we want to modify in the end
                totalRange = NSUnionRange(listRange, totalRange);
            }
        }
    }
    
    // get a mutable substring for the total range
    NSMutableAttributedString *mutableText = [[attributedText attributedSubstringFromRange:totalRange] mutableCopy];
    
    // remember the current selection in the mutableText
    NSRange tmpRange = [(DTTextRange *)self.selectedTextRange NSRangeValue];
    tmpRange.location -= totalRange.location;
    [mutableText addMarkersForSelectionRange:tmpRange];
    
    // modify
    NSRange mutableRange = NSMakeRange(0, mutableText.length);
    
    if (!listStyle)
    {
        // only modify selected paragraphs
        mutableRange = paragraphRange;
        mutableRange.location -= totalRange.location;

        // split lists
        if (totalRange.location<paragraphRange.location)
        {
            listBeforeSelection = [listAroundSelection copy];
            
            // from start to the beginning of the selected paragraph
            NSRange updateRange = NSMakeRange(0, mutableRange.location);
            [mutableText updateListStyle:listBeforeSelection inRange:updateRange numberFrom:listBeforeSelection.startingItemNumber];
        }
        
        if (NSMaxRange(paragraphRange)<NSMaxRange(totalRange))
        {
            listAfterSelection = [listAroundSelection copy];
            
            // from character after the selected paragraphs until end of modified region
            NSInteger indexAfterSelectedParagraphs = NSMaxRange(mutableRange);
            NSRange updateRange = NSMakeRange(indexAfterSelectedParagraphs, mutableText.length - indexAfterSelectedParagraphs + 1);
            [mutableText updateListStyle:listAfterSelection inRange:updateRange numberFrom:listAfterSelection.startingItemNumber];
        }
    }
    
    [mutableText updateListStyle:listStyle inRange:mutableRange numberFrom:listStyle.startingItemNumber];
    
    // get modified selection range and remove marking from substitution string
    NSRange rangeToSelectAfterwards = [mutableText markedRangeRemove:YES];
    rangeToSelectAfterwards.location += totalRange.location;
    
    // substitute
    [self.inputDelegate textWillChange:self];
    [self replaceRange:[DTTextRange rangeWithNSRange:totalRange] withText:mutableText];
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
