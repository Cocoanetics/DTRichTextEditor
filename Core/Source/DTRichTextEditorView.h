//
//  DTRichTextEditorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTAttributedTextView.h"
#import "DTAttributedTextContentView.h"
#import "NSAttributedString+DTRichText.h"


extern NSString * const DTRichTextEditorTextDidBeginEditingNotification;

@class DTTextRange, DTTextPosition;
@class DTCursorView;
@class DTLoupeView;
@class DTTextSelectionView;
@class DTCSSListStyle;


typedef enum
{
	DTDragModeNone = 0,
	DTDragModeLeftHandle,
	DTDragModeRightHandle,
	DTDragModeCursor,
	DTDragModeCursorInsideMarking
} DTDragMode;

/**
 DTRichTextEditorView is a subclass of UIScrollView and offers rich text edtiting capabilities. It has a single content view of type DTRichTextEditorContentView which is repsonsible for displaying the rich text.
 
 
 
 
 */



@interface DTRichTextEditorView : DTAttributedTextView <UITextInputTraits, UITextInput>

@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic, assign) BOOL replaceParagraphsWithLineFeeds;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property(nonatomic, assign) id<UITextInputDelegate> inputDelegate;
@property (nonatomic, copy) NSDictionary *markedTextStyle;
@property (nonatomic) UITextStorageDirection selectionAffinity;

/**
 Overrides for textDefaults. If they are set then they are used instead of the values contained in textDefaults.
 */
@property (nonatomic, assign) CGSize maxImageDisplaySize;
@property (nonatomic, copy) NSString *defaultFontFamily;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, assign) CGFloat textSizeMultiplier;


@property (nonatomic, retain) DTCursorView *cursor;

@property (retain, readwrite) UIView *inputView;
@property (retain, readwrite) UIView *inputAccessoryView;

// UITextInputTraits
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
//@property(nonatomic) UITextSpellCheckingType spellCheckingType;

// overwritten, accepts NSString or NSAttributedString
- (void)replaceRange:(UITextRange *)range withText:(id)text;

- (void)scrollCursorVisibleAnimated:(BOOL)animated;

- (void)setSelectedTextRange:(DTTextRange *)newTextRange animated:(BOOL)animated;


@property (nonatomic, assign) BOOL canInteractWithPasteboard;

@end



@interface DTRichTextEditorView (manipulation)

- (DTTextRange *)rangeForWordAtPosition:(DTTextPosition *)position;

- (NSDictionary *)defaultAttributes;
- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;
- (UITextRange *)textRangeOfURLAtPosition:(UITextPosition *)position URL:(NSURL **)URL;

- (void)replaceRange:(UITextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

- (void)toggleBoldInRange:(UITextRange *)range;
- (void)toggleItalicInRange:(UITextRange *)range;
- (void)toggleUnderlineInRange:(UITextRange *)range;

- (void)toggleHighlightInRange:(UITextRange *)range color:(UIColor *)color;

// make a range a hyperlink or remove it
- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL;

- (void)applyTextAlignment:(CTTextAlignment)alignment toParagraphsContainingRange:(UITextRange *)range;
- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range;

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;
- (void)relayoutText;

- (BOOL)pasteboardHasSuitableContentForPaste;
- (NSString *)plainTextForRange:(UITextRange *)range;

- (void)setHTMLString:(NSString *)string;

- (CGRect)visibleContentRect;
- (BOOL)selectionIsVisible;

/**
 The default options to be used for text. See the options parameter of <DTHTMLAttributedStringBuilder> for individual options.
 
 If one of these properties is set then it is used instead of the value contained in textDefaults:
 
 - maxImageDisplaySize
 - defaultFontFamily
 - baseURL;
 - textSizeMultiplier;
 
 NOTE: Changing these defaults does not affect the current `NSAttributedString`. They are used when calling setHTMLString. 
*/
@property (nonatomic, retain) NSDictionary *textDefaults;

@end


#pragma mark CoreText

@class DTCoreTextLayoutLine;

@interface DTRichTextEditorView (CoreText)

- (NSUInteger)numberOfLayoutLines;
- (DTCoreTextLayoutLine *)layoutLineAtIndex:(NSUInteger)lineIndex;
- (DTCoreTextLayoutLine *)layoutLineContainingTextPosition:(DTTextPosition *)textPosition;
- (NSArray *)visibleLayoutLines;

@end
