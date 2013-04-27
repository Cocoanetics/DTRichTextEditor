//
//  DTRichTextEditorView+Manipulation.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 17.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditor.h"
#import "DTUndoManager.h"

@interface DTRichTextEditorView (private)

- (void)updateCursorAnimated:(BOOL)animated;
- (void)hideContextMenu;
- (void)_closeTypingUndoGroupIfNecessary;

@end


@implementation DTRichTextEditorView (Manipulation)

#pragma mark - Getting/Setting content

- (NSAttributedString *)attributedSubstringForRange:(UITextRange *)range
{
	DTTextRange *textRange = (DTTextRange *)range;
	
	return [self.attributedTextContentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:[textRange NSRangeValue]];
}

- (DTCoreTextGlyphRun *)glyphRunAtPosition:(UITextPosition *)position
{
    NSParameterAssert(position);
    
    DTCoreTextLayoutLine *lineWithPosition = [self layoutLineContainingTextPosition:position];
//    NSString *string = [[self.attributedText string] substringWithRange:[lineWithPosition stringRange]];
    
     if (!lineWithPosition)
    {
        return nil;
    }
    
    NSUInteger location = [(DTTextPosition *)position location];
    NSArray *glyphRuns = [lineWithPosition glyphRunsWithRange:NSMakeRange(location, 1)];
    
    return [glyphRuns lastObject];
}

- (void)setHTMLString:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:data options:[self textDefaults] documentAttributes:NULL];
	
	[self setAttributedText:attributedString];
	
	[self.undoManager removeAllActions];
}

- (NSString *)plainTextForRange:(UITextRange *)range
{
	if (!range)
	{
		return nil;
	}
	
	NSRange textRange = [(DTTextRange *)range NSRangeValue];
	
	NSString *tmpString = [[self.attributedTextContentView.layoutFrame.attributedStringFragment string] substringWithRange:textRange];
	
	tmpString = [tmpString stringByReplacingOccurrencesOfString:UNICODE_OBJECT_PLACEHOLDER withString:@""];
	
	return tmpString;
};

- (NSDictionary *)typingAttributesForRange:(DTTextRange *)range
{
	NSDictionary *attributes = [self.attributedTextContentView.layoutFrame.attributedStringFragment typingAttributesForRange:[range NSRangeValue]];
	
	CTFontRef font = (__bridge CTFontRef)[attributes objectForKey:(id)kCTFontAttributeName];
	CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[attributes objectForKey:(id)kCTParagraphStyleAttributeName];
	
	if (font&&paragraphStyle)
	{
		return attributes;
	}
	
	// otherwise we need to add missing things
	
	NSDictionary *defaults = [self textDefaults];
	NSString *fontFamily = [defaults objectForKey:DTDefaultFontFamily];
    NSNumber *fontSize = [defaults objectForKey:DTDefaultFontSize];
	
	CGFloat multiplier = [[defaults objectForKey:NSTextSizeMultiplierDocumentOption] floatValue];
	
	if (!multiplier)
	{
		multiplier = 1.0;
	}
	
	NSMutableDictionary *tmpAttributes = [attributes mutableCopy];
	
	// if there's no font, then substitute it from our defaults
	if (!font)
	{
		DTCoreTextFontDescriptor *desc = [[DTCoreTextFontDescriptor alloc] init];
		desc.fontFamily = fontFamily;
        desc.pointSize = [fontSize floatValue] * multiplier;
		
		CTFontRef defaultFont = [desc newMatchingFont];
		
		[tmpAttributes setObject:(__bridge id)defaultFont forKey:(id)kCTFontAttributeName];
		
		CFRelease(defaultFont);
	}
	
	if (!paragraphStyle)
	{
		DTCoreTextParagraphStyle *defaultStyle = [DTCoreTextParagraphStyle defaultParagraphStyle];
		defaultStyle.paragraphSpacing = [fontSize floatValue]  * multiplier;
		
		paragraphStyle = [defaultStyle createCTParagraphStyle];
		
		[tmpAttributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
		
		CFRelease(paragraphStyle);
	}
	
	return tmpAttributes;
}

@dynamic overrideInsertionAttributes; // provided by DTRichTextEditorView main implementation


#pragma mark - Pasteboard

- (BOOL)pasteboardHasSuitableContentForPaste
{
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	
	if ([pasteboard containsPasteboardTypes:UIPasteboardTypeListString])
	{
		return YES;
	}
	
	if ([pasteboard containsPasteboardTypes:UIPasteboardTypeListImage])
	{
		return YES;
	}
	
	if ([pasteboard containsPasteboardTypes:UIPasteboardTypeListURL])
	{
		return YES;
	}
	
	if ([pasteboard webArchive])
	{
		return YES;
	}
	
	return NO;
}

#pragma mark - Utilities

// updates a text framement by replacing it with a new string
- (void)_updateSubstringInRange:(NSRange)range withAttributedString:(NSAttributedString *)attributedString actionName:(NSString *)actionName
{
	NSAssert([attributedString length] == range.length, @"lenght of updated string and update attributed string must match");

	NSUndoManager *undoManager = self.undoManager;
	
	NSAttributedString *replacedString = [self.attributedTextContentView.attributedString attributedSubstringFromRange:range];
	
	[[undoManager prepareWithInvocationTarget:self] _updateSubstringInRange:range withAttributedString:replacedString actionName:actionName];
	
	if (actionName)
	{
		[undoManager setActionName:actionName];
	}
	
	// replace
	[(DTRichTextEditorContentView *)self.attributedTextContentView replaceTextInRange:range withText:attributedString];
	
	// attachment positions might have changed
	[self.attributedTextContentView layoutSubviewsInRect:self.bounds];
	
	// cursor positions might have changed
	[self updateCursorAnimated:NO];
}

- (void)_closeTypingUndoGroupIfNecessary
{
	DTUndoManager *undoManager = (DTUndoManager *)self.undoManager;
	
	[undoManager closeAllOpenGroups];
}

#pragma mark - Toggling Styles for Ranges

- (void)toggleBoldInRange:(DTTextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	if ([range isEmpty])
	{
		// if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}
		[tmpDict toggleBold];
		self.overrideInsertionAttributes = tmpDict;
	}
	else
	{
		NSRange styleRange = [(DTTextRange *)range NSRangeValue];
		
		// get fragment that is to be made bold
		NSMutableAttributedString *fragment = [[[self.attributedTextContentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament bold
		[fragment toggleBoldInRange:NSMakeRange(0, [fragment length])];
	
		// replace
		[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Bold", @"Action that makes text bold")];
	}
	
	[self hideContextMenu];
}

- (void)toggleItalicInRange:(DTTextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	if ([range isEmpty])
	{
		// if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}
		[tmpDict toggleItalic];
		self.overrideInsertionAttributes = tmpDict;
	}
	else
	{
		NSRange styleRange = [(DTTextRange *)range NSRangeValue];
		
		// get fragment that is to be made italic
		NSMutableAttributedString *fragment = [[[self.attributedTextContentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament italic
		[fragment toggleItalicInRange:NSMakeRange(0, [fragment length])];

		// replace
		[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Italic", @"Action that makes text italic")];
	}
	
	[self hideContextMenu];
}

- (void)toggleUnderlineInRange:(DTTextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	if ([range isEmpty])
	{
		// if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}
		[tmpDict toggleUnderline];
		self.overrideInsertionAttributes = tmpDict;
	}
	else
	{
		NSRange styleRange = [(DTTextRange *)range NSRangeValue];
		
		// get fragment that is to be made underlined
		NSMutableAttributedString *fragment = [[[self.attributedTextContentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament underlined
		[fragment toggleUnderlineInRange:NSMakeRange(0, [fragment length])];
		
		// replace
		[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Underline", @"Action that makes text underlined")];
	}
	
	[self hideContextMenu];
}

- (void)toggleHighlightInRange:(DTTextRange *)range color:(UIColor *)color
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	if ([range isEmpty])
	{
		// if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}
		[tmpDict toggleHighlightWithColor:color];
		self.overrideInsertionAttributes = tmpDict;
	}
	else
	{
		NSRange styleRange = [(DTTextRange *)range NSRangeValue];
		
		// get fragment that is to be made bold
		NSMutableAttributedString *fragment = [[[self.attributedTextContentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament highlighted
		[fragment toggleHighlightInRange:NSMakeRange(0, [fragment length]) color:color];
		
		// replace
		[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Highlight", @"Action that adds a colored background behind text to highlight it")];
	}
	
	[self hideContextMenu];
}

- (void)setForegroundColor:(UIColor *)color inRange:(UITextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];
	
	if ([range isEmpty])
	{
		// if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}
		
		[tmpDict setForegroundColor:color];
		self.overrideInsertionAttributes = tmpDict;
	}
	else
	{
		NSRange styleRange = [(DTTextRange *)range NSRangeValue];
		
		// get fragment that is to be made bold
		NSMutableAttributedString *fragment = [[self attributedSubstringForRange:range] mutableCopy];
		
		// set the color
		[fragment setForegroundColor:color inRange:NSMakeRange(0, [fragment length])];
		
		// replace
		[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Text Color", @"Action that sets the text color")];
	}
	
	[self hideContextMenu];
}

- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	// if there is an URL at the cursor position we assume it
	NSURL *effectiveURL = nil;
	UITextRange *effectiveRange = [self textRangeOfURLAtPosition:range.start URL:&effectiveURL];
	
	if ([effectiveURL isEqual:URL])
	{
		// toggle URL off
		URL = nil;
	}
	
	if ([range isEmpty])
	{
		if (effectiveRange)
		{
			// work with the effective range instead
			range = effectiveRange;
		}
		else
		{
			// cannot toggle with empty range
			return;
		}
	}
	
	NSRange styleRange = [(DTTextRange *)range NSRangeValue];
	
	// get fragment that is to be toggled
	NSMutableAttributedString *fragment = [[[self.attributedTextContentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
	
	// toggle entire frament
	NSRange entireFragmentRange = NSMakeRange(0, [fragment length]);
	[fragment toggleHyperlinkInRange:entireFragmentRange URL:URL];
	
	NSDictionary *textDefaults = self.textDefaults;
	
	// remove extra stylings
	[fragment removeAttribute:(id)kCTUnderlineStyleAttributeName range:entireFragmentRange];
	
	// assume normal text color is black
	[fragment addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:entireFragmentRange];
	
	if (URL)
	{
		if ([[textDefaults objectForKey:DTDefaultLinkDecoration] boolValue])
		{
			[fragment addAttribute:(id)kCTUnderlineStyleAttributeName  value:[NSNumber numberWithInteger:1] range:entireFragmentRange];
		}
		
		UIColor *linkColor = [textDefaults objectForKey:DTDefaultLinkColor];
		
		if (linkColor)
		{
			[fragment addAttribute:(id)kCTForegroundColorAttributeName value:(id)linkColor.CGColor range:entireFragmentRange];
		}
		
	}
	
	// need to style the text accordingly
	
	// replace
	[self _updateSubstringInRange:styleRange withAttributedString:fragment actionName:NSLocalizedString(@"Hyperlink", @"Action that toggles text to be a hyperlink")];
	
	[self hideContextMenu];
}

#pragma mark - Working with Fonts

- (void)updateFontInRange:(UITextRange *)range withFontFamilyName:(NSString *)fontFamilyName pointSize:(CGFloat)pointSize
{
    // close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];
    
    if ([range isEmpty])
    {
        // if we only have a cursor then we save the attributes for the next insertion
		NSMutableDictionary *tmpDict = [self.overrideInsertionAttributes mutableCopy];
		
		if (!tmpDict)
		{
			tmpDict = [[self typingAttributesForRange:range] mutableCopy];
		}

        DTCoreTextFontDescriptor *fontDescriptor = [[DTCoreTextFontDescriptor alloc] init];
        
        fontDescriptor.fontFamily = fontFamilyName;
        fontDescriptor.pointSize = pointSize;
        
		[tmpDict setFontFromFontDescriptor:fontDescriptor];
		self.overrideInsertionAttributes = tmpDict;
        
        return;
    }
    
    NSMutableAttributedString *fragment = [[self attributedSubstringForRange:range] mutableCopy];
    
    BOOL didUpdate = [fragment enumerateAndUpdateFontInRange:NSMakeRange(0, [fragment length]) block:^BOOL(DTCoreTextFontDescriptor *fontDescriptor, BOOL *stop) {
        BOOL shouldUpdate = NO;
        
        if (fontFamilyName && ![fontFamilyName isEqualToString:fontDescriptor.fontFamily])
        {
            fontDescriptor.fontFamily = fontFamilyName;

            // need to wipe these or else the matching font might be wrong
            fontDescriptor.fontName = nil;
            fontDescriptor.symbolicTraits = 0;
            
            shouldUpdate = YES;
        }
        
        if (pointSize && pointSize!=fontDescriptor.pointSize)
        {
            fontDescriptor.pointSize = pointSize;
            
            shouldUpdate = YES;
        }
        
        return shouldUpdate;
    }];
    
    if (didUpdate)
    {
        // replace
        [self _updateSubstringInRange:[(DTTextRange *)range NSRangeValue] withAttributedString:fragment actionName:NSLocalizedString(@"Set Font", @"Undo Action that replaces the font for a range")];
         }
    
    [self hideContextMenu];
}

- (DTCoreTextFontDescriptor *)fontDescriptorForRange:(UITextRange *)range
{
    NSDictionary *typingAttributes = [self typingAttributesForRange:range];
    
    CTFontRef font = (__bridge CTFontRef)[typingAttributes objectForKey:(id)kCTFontAttributeName];
    
    if (!font)
    {
        return nil;
    }
    
    return [DTCoreTextFontDescriptor fontDescriptorForCTFont:font];
}

- (void)setFont:(UIFont *)font
{
    NSParameterAssert(font);
    
    CTFontRef ctFont = DTCTFontCreateWithUIFont(font);
    DTCoreTextFontDescriptor *fontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:ctFont];
	CFRelease(ctFont);
	
    
    // put these values into the defaults
    self.defaultFontSize = fontDescriptor.pointSize;
    self.defaultFontFamily = fontDescriptor.fontFamily;
	
	// scale it
	fontDescriptor.pointSize *= self.textSizeMultiplier;

	// create a new font
	ctFont = [fontDescriptor newMatchingFont];
   
	NSAttributedString *attributedString = self.attributedTextContentView.layoutFrame.attributedStringFragment;
	
	if (![attributedString length])
	{
		return;
	}
	
	NSRange fullRange = NSMakeRange(0, [attributedString length]);
	NSMutableAttributedString *fragment = [[attributedString attributedSubstringFromRange:fullRange] mutableCopy];

	[fragment addAttribute:(id)kCTFontAttributeName value:(__bridge id)ctFont range:fullRange];
	
	CFRelease(ctFont);
	
	[self _updateSubstringInRange:fullRange withAttributedString:fragment actionName:NSLocalizedString(@"Set Font", @"Undo Action that replaces the font for a range")];
}

#pragma mark - Changing Paragraph Styles

- (BOOL)applyTextAlignment:(CTTextAlignment)alignment toParagraphsContainingRange:(UITextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];
	
	DTTextRange *paragraphRange = (DTTextRange *)[self textRangeOfParagraphsContainingRange:range];
	NSMutableAttributedString *fragment = [[self attributedSubstringForRange:paragraphRange] mutableCopy];
	
	// adjust
	NSRange entireRange = NSMakeRange(0, [fragment length]);
	BOOL didUpdate = [fragment enumerateAndUpdateParagraphStylesInRange:entireRange block:^BOOL(DTCoreTextParagraphStyle *paragraphStyle, BOOL *stop) {
		if (paragraphStyle.alignment != alignment)
		{
			paragraphStyle.alignment = alignment;
			return YES;
		}
		
		return NO;
	}];

	if (didUpdate)
	{
		// replace
		[self _updateSubstringInRange:[paragraphRange NSRangeValue] withAttributedString:fragment actionName:NSLocalizedString(@"Alignment", @"Action that adjusts paragraph alignment")];
	}
	
	[self hideContextMenu];

	return didUpdate;
}

- (void)changeParagraphLeftMarginBy:(CGFloat)delta toParagraphsContainingRange:(UITextRange *)range
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	DTTextRange *paragraphRange = (DTTextRange *)[self textRangeOfParagraphsContainingRange:range];
	NSMutableAttributedString *fragment = [[self attributedSubstringForRange:paragraphRange] mutableCopy];
	
	// adjust
	NSRange entireRange = NSMakeRange(0, [fragment length]);
	BOOL didUpdate = [fragment enumerateAndUpdateParagraphStylesInRange:entireRange block:^BOOL(DTCoreTextParagraphStyle *paragraphStyle, BOOL *stop) {
		
		CGFloat newFirstLineIndent = paragraphStyle.firstLineHeadIndent + delta;
		
		if (newFirstLineIndent < 0)
		{
			newFirstLineIndent = 0;
		}
		
		CGFloat newOtherLineIndent = paragraphStyle.headIndent + delta;

		if (newOtherLineIndent < 0)
		{
			newOtherLineIndent = 0;
		}
		
		paragraphStyle.firstLineHeadIndent = newFirstLineIndent;
		paragraphStyle.headIndent = newOtherLineIndent;

		return YES;
	}];
	
	if (didUpdate)
	{
		// replace
		[self _updateSubstringInRange:[paragraphRange NSRangeValue] withAttributedString:fragment actionName:NSLocalizedString(@"Indent", @"Action that changes the indentation of a paragraph")];
	}
	
	[self hideContextMenu];
}

#pragma mark - Working with Attachments

- (void)replaceRange:(DTTextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
	// close off typing group, this is a new operations
	[self _closeTypingUndoGroupIfNecessary];

	NSRange textRange = [(DTTextRange *)range NSRangeValue];
	
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
	NSString *plainText = [self.attributedTextContentView.layoutFrame.attributedStringFragment string];
	
	if (inParagraph)
	{
		// determine if we need a paragraph break before or after the item
		if (textRange.location>0)
		{
			NSInteger index = textRange.location-1;
			
			unichar character = [plainText characterAtIndex:index];
			
			if (character != '\n')
			{
				needsParagraphBefore = YES;
			}
		}
		
		NSUInteger indexAfterRange = NSMaxRange(textRange);
		if (indexAfterRange<[plainText length])
		{
			unichar character = [plainText characterAtIndex:indexAfterRange];
			
			if (character != '\n')
			{
				needsParagraphAfter = YES;
			}
		}
	}
	NSMutableAttributedString *tmpAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
	
	if (needsParagraphBefore)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	NSMutableDictionary *objectAttributes = [attributes mutableCopy];
	
	// need run delegate for sizing
	CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate((id)attachment);
	[objectAttributes setObject:(__bridge id)embeddedObjectRunDelegate forKey:(id)kCTRunDelegateAttributeName];
	CFRelease(embeddedObjectRunDelegate);
	
	// add attachment
	[objectAttributes setObject:attachment forKey:NSAttachmentAttributeName];
	
	// get the font
	CTFontRef font = (__bridge CTFontRef)[objectAttributes objectForKey:(__bridge NSString *) kCTFontAttributeName];
	if (font)
	{
		[attachment adjustVerticalAlignmentForFont:font];
	}
	
	NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:UNICODE_OBJECT_PLACEHOLDER attributes:objectAttributes];
	[tmpAttributedString appendAttributedString:tmpStr];
	
	if (needsParagraphAfter)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[tmpAttributedString appendAttributedString:formattedNL];
	}
	
	DTTextRange *replacementRange = [DTTextRange rangeWithNSRange:textRange];
	[self replaceRange:replacementRange withText:tmpAttributedString];

	// change undo action name from typing to inserting image
	[self.undoManager setActionName:NSLocalizedString(@"Insert Image", @"Undoable Action")];
}



- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate
{
	// update all attachments that matchin this URL (possibly multiple images with same size)
	return [self.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:predicate];
}

@end
