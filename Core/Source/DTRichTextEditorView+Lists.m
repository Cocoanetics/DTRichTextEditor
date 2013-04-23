//
//  DTRichTextEditorView+Lists.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"
#import "NSAttributedString+DTRichText.h"

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


- (CGFloat)_paragraphSpacingAfterListOfStyle:(DTCSSListStyle *)listStyle relativeToTextSize:(CGFloat)textSize
{
    NSString *tagName = @"p";
    
    if (listStyle)
    {
        if ([listStyle isOrdered])
        {
            tagName = @"ol";
        }
        else
        {
            tagName = @"ul";
        }
    }

    DTCoreTextParagraphStyle *paragraphStyle = [self paragraphStyleForTagName:tagName tagClass:nil tagIdentifier:nil relativeToTextSize:textSize];

    return paragraphStyle.paragraphSpacing;
}


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

            // get font size at beginning of last paragraph of list
            NSRange lastParagraph = [[mutableText string] rangeOfParagraphAtIndex:NSMaxRange(updateRange)-1];
            CTFontRef font = (__bridge CTFontRef)([mutableText attribute:(id)kCTFontAttributeName atIndex:lastParagraph.location effectiveRange:NULL]);
            CGFloat fontSize = CTFontGetSize(font) * self.textSizeMultiplier;

            // get the paragraph spacing after the list
            CGFloat paragraphSpacing = [self _paragraphSpacingAfterListOfStyle:listBeforeSelection relativeToTextSize:fontSize];
            
            // refresh the list before the un-toggled portion
			[mutableText updateListStyle:listBeforeSelection inRange:updateRange numberFrom:listBeforeSelection.startingItemNumber listIndent:[self listIndentForListStyle:listBeforeSelection] spacingAfterList:paragraphSpacing];
		}
		
		if (NSMaxRange(paragraphRange)<NSMaxRange(totalRange))
		{
			listAfterSelection = [listAroundSelection copy];
			
			// from character after the selected paragraphs until end of modified region
			NSInteger indexAfterSelectedParagraphs = NSMaxRange(mutableRange);
			NSRange updateRange = NSMakeRange(indexAfterSelectedParagraphs, mutableText.length - indexAfterSelectedParagraphs);
            
            // get font size at beginning of last paragraph of list
            NSRange lastParagraph = [[mutableText string] rangeOfParagraphAtIndex:NSMaxRange(updateRange)-1];
            CTFontRef font = (__bridge CTFontRef)([mutableText attribute:(id)kCTFontAttributeName atIndex:lastParagraph.location effectiveRange:NULL]);
            CGFloat fontSize = CTFontGetSize(font) * self.textSizeMultiplier;
            
            // get the paragraph spacing after the list
            CGFloat paragraphSpacing = [self _paragraphSpacingAfterListOfStyle:listAfterSelection relativeToTextSize:fontSize];

            // refresh the list before the un-toggled portion
			[mutableText updateListStyle:listAfterSelection inRange:updateRange numberFrom:listAfterSelection.startingItemNumber listIndent:[self listIndentForListStyle:listAfterSelection] spacingAfterList:paragraphSpacing];
		}
	}

	
    // get font size at beginning of last paragraph of list
    NSRange lastParagraph = [[mutableText string] rangeOfParagraphAtIndex:NSMaxRange(mutableRange)-1];
    CTFontRef font = (__bridge CTFontRef)([mutableText attribute:(id)kCTFontAttributeName atIndex:lastParagraph.location effectiveRange:NULL]);
    CGFloat fontSize = CTFontGetSize(font) * self.textSizeMultiplier;
    
    // get the paragraph spacing after the list
    CGFloat paragraphSpacing = [self _paragraphSpacingAfterListOfStyle:listAfterSelection relativeToTextSize:fontSize];
    
    // update to list style
	[mutableText updateListStyle:listStyle inRange:mutableRange numberFrom:listStyle.startingItemNumber listIndent:[self listIndentForListStyle:listStyle] spacingAfterList:paragraphSpacing];
	
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

- (BOOL)handleNewLineInputInListInRange:(UITextRange *)range
{
	NSRange selectionRange = [(DTTextRange *)range NSRangeValue];
	NSAttributedString *attributedText = self.attributedText;
	NSRange selectedParagraphRange = [attributedText.string rangeOfParagraphsContainingRange:selectionRange parBegIndex:NULL parEndIndex:NULL];
	
	NSDictionary *attributes = [attributedText attributesAtIndex:selectedParagraphRange.location effectiveRange:NULL];
	DTCSSListStyle *effectiveList = [[attributes objectForKey:DTTextListsAttribute] lastObject];
	
	NSRange listRange = [attributedText rangeOfTextList:effectiveList atIndex:selectedParagraphRange.location];
	
	// not a list, nothing to do
	if (!effectiveList)
	{
		return NO;
	}
	
	// need to replace attributes with typing attributes
	NSAttributedString *newlineText = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
	
	// NL on last paragraph of list removes it from list
	if (selectionRange.location>0 && NSMaxRange(selectedParagraphRange) == NSMaxRange(listRange))
	{
		NSRange listPrefixRange = [attributedText rangeOfListPrefixAtIndex:selectedParagraphRange.location];
		
		if (NSMaxRange(listPrefixRange) == selectionRange.location)
		{
			BOOL paragraphIsEmpty = (NSMaxRange(selectedParagraphRange)-1 == selectionRange.location);
			
			if (paragraphIsEmpty)
			{
				[self toggleListStyle:nil inRange:range];
            
				return YES;
			}
		}
	}
	
	NSRange totalRange = NSUnionRange(listRange, selectionRange);
	
	// get a mutable substring for the total range
	NSMutableAttributedString *mutableText = [[attributedText attributedSubstringFromRange:totalRange] mutableCopy];
	
	// do the replacement
	NSRange partSelectionRange = selectionRange;
	partSelectionRange.location -= totalRange.location;
	
	// mark the selection on first character after selection
	[mutableText addMarkersForSelectionRange:NSMakeRange(NSMaxRange(partSelectionRange), 0)];
	
	[mutableText replaceCharactersInRange:partSelectionRange withAttributedString:newlineText];
	
	NSRange mutableRange = NSMakeRange(0, mutableText.length);
	
    // get font size at beginning of last paragraph of list
    NSRange lastParagraph = [[mutableText string] rangeOfParagraphAtIndex:NSMaxRange(mutableRange)-1];
    CTFontRef font = (__bridge CTFontRef)([mutableText attribute:(id)kCTFontAttributeName atIndex:lastParagraph.location effectiveRange:NULL]);
    CGFloat fontSize = CTFontGetSize(font) * self.textSizeMultiplier;
    
    // get the paragraph spacing after the list
    CGFloat paragraphSpacing = [self _paragraphSpacingAfterListOfStyle:effectiveList relativeToTextSize:fontSize];
    
	// now update the entire list
	[mutableText updateListStyle:effectiveList inRange:mutableRange numberFrom:effectiveList.startingItemNumber listIndent:[self listIndentForListStyle:effectiveList] spacingAfterList:paragraphSpacing];
	
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
	
	return YES;
}

// returns all effective lists intersecting the given range
- (NSSet *)_listsInRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange
{
	NSMutableSet *tmpSet = [NSMutableSet set];
	
	__block NSRange rangeIncludingAllAffectedLists = range;
	
	if (!range.length)
	{
		range.length = 1;
	}
	
	
	NSAttributedString *attributedText = self.attributedText;
	
	if (NSMaxRange(range)>attributedText.length)
	{
		return nil;
	}
	
	[attributedText enumerateAttribute:DTTextListsAttribute inRange:range options:0 usingBlock:^(NSArray *lists, NSRange attributeRange, BOOL *stop) {
		if ([lists count])
		{
			[tmpSet addObjectsFromArray:lists];
			
			DTCSSListStyle *effectiveList = [lists lastObject];
			NSRange listRange = [attributedText rangeOfTextList:effectiveList atIndex:attributeRange.location];
			rangeIncludingAllAffectedLists = NSUnionRange(rangeIncludingAllAffectedLists, listRange);
		}
	}];
	
	if (effectiveRange)
	{
		*effectiveRange = rangeIncludingAllAffectedLists;
	}
	
	return [tmpSet copy];
}

- (NSRange)_findList:(DTCSSListStyle *)list inAttributedString:(NSAttributedString *)attributedString
{
	__block NSRange foundRange = NSMakeRange(NSNotFound, 0);
	
	NSRange entireRange = NSMakeRange(0, [attributedString length]);
	[attributedString enumerateAttribute:DTTextListsAttribute inRange:entireRange options:0 usingBlock:^(NSArray *lists, NSRange range, BOOL *stop) {
		if ([lists containsObject:list])
		{
			foundRange = [attributedString rangeOfTextList:list atIndex:range.location];
			*stop = YES;
		}
	}];
	
	return foundRange;
}


- (void)updateListsInRange:(UITextRange *)range
{
	NSRange selectionRange = [(DTTextRange *)range NSRangeValue];
	NSRange selectedParagraphRange = [self.attributedText.string rangeOfParagraphsContainingRange:selectionRange parBegIndex:NULL parEndIndex:NULL];
	
	NSRange rangeOfAllLists;
	NSSet *listsInRange = [self _listsInRange:selectedParagraphRange effectiveRange:&rangeOfAllLists];
	
	if (![listsInRange count])
	{
		// nothing to do
		return;
	}

	NSRange totalRange = NSUnionRange(selectedParagraphRange, rangeOfAllLists);
	NSRange partSelectionRange = selectionRange;
	partSelectionRange.location -= totalRange.location;

	// get entire region that needs work
	NSMutableAttributedString *mutableText = [[self.attributedText attributedSubstringFromRange:totalRange] mutableCopy];

	// mark the selection on first character after selection
	[mutableText addMarkersForSelectionRange:NSMakeRange(NSMaxRange(partSelectionRange), 0)];
	
	for (DTCSSListStyle *oneList in listsInRange)
	{
		// find the range of this list
		NSRange listRange = [self _findList:oneList inAttributedString:mutableText];
		
        // get font size at beginning of last paragraph of list
        NSRange lastParagraph = [[mutableText string] rangeOfParagraphAtIndex:NSMaxRange(listRange)-1];
        CTFontRef font = (__bridge CTFontRef)([mutableText attribute:(id)kCTFontAttributeName atIndex:lastParagraph.location effectiveRange:NULL]);
        CGFloat fontSize = CTFontGetSize(font) * self.textSizeMultiplier;
        
        // get the paragraph spacing after the list
        CGFloat paragraphSpacing = [self _paragraphSpacingAfterListOfStyle:oneList relativeToTextSize:fontSize];
        
		[mutableText updateListStyle:oneList inRange:listRange numberFrom:oneList.startingItemNumber listIndent:[self listIndentForListStyle:oneList] spacingAfterList:paragraphSpacing];
	}

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
}

@end
