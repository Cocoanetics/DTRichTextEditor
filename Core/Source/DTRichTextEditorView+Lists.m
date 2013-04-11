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
    DTCSSListStyle *listAtPosition = [[attributedText attribute:DTTextListsAttribute atIndex:index effectiveRange:NULL] lastObject];
    
    NSRange totalRange = paragraphRange;
    
    if (listAtPosition)
    {
        // find extent of this list
        NSRange listRange = [attributedText rangeOfTextList:listAtPosition atIndex:index];
        
        // join up all ranges, this is the range we want to modify in the end
        totalRange = NSUnionRange(listRange, paragraphRange);
        
        if (listAtPosition.type == listStyle.type)
        {
            // remove list (= toggle)
            listStyle = nil;
        }
    }
    else
    {
        DTCSSListStyle *extendingList = nil;
        
        // check if extending a list on the paragraph before the selection
        if (paragraphRange.location > 0)
        {
            extendingList = [[attributedText attribute:DTTextListsAttribute atIndex:paragraphRange.location-1 effectiveRange:NULL] lastObject];
            
            // if same type we extend the list
            if (extendingList.type == listStyle.type)
            {
                // find extent of this list
                NSRange listRange = [attributedText rangeOfTextList:extendingList atIndex:paragraphRange.location-1];
                
                // join up all ranges, this is the range we want to modify in the end
                totalRange = NSUnionRange(listRange, totalRange);
            }
        }

        // check if extending a list on the paragraph after the selection
        if (NSMaxRange(paragraphRange) < attributedText.length)
        {
            extendingList = [[attributedText attribute:DTTextListsAttribute atIndex:NSMaxRange(paragraphRange) effectiveRange:NULL] lastObject];
            
            // if same type we extend the list
            if (extendingList.type == listStyle.type)
            {
                // find extent of this list
                NSRange listRange = [attributedText rangeOfTextList:extendingList atIndex:NSMaxRange(paragraphRange)];
                
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
