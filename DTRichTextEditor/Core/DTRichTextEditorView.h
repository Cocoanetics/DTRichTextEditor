//
//  DTRichTextEditorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTAttributedTextView.h"
#import "DTAttributedTextContentView.h"
#import "NSAttributedString+DTRichText.h"

@class DTTextRange, DTTextPosition;
@class DTCursorView;
@class DTLoupeView;
@class DTTextSelectionView;

typedef enum
{
	DTDragModeNone = 0,
	DTDragModeLeftHandle,
	DTDragModeRightHandle,
	DTDragModeCursor
} DTDragMode;


@interface DTRichTextEditorView : DTAttributedTextView <UITextInputTraits, UITextInput, DTAttributedTextContentViewDelegate, UIGestureRecognizerDelegate>
{
	NSMutableAttributedString *_internalAttributedText;
	
	id<UITextInputTokenizer> tokenizer;
	id<UITextInputDelegate> inputDelegate;
	NSDictionary *markedTextStyle;
	
	DTTextRange *_selectedTextRange;
	DTTextRange *_markedTextRange;
    
    UITextStorageDirection _selectionAffinity;
	
	// UITextInputTraits
	UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
	UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
	BOOL enablesReturnKeyAutomatically;                  // default is NO
	UIKeyboardAppearance keyboardAppearance;             // default is UIKeyboardAppearanceDefault
	UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
	UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
    BOOL secureTextEntry;                                // default is NO
	
  //  UITextSpellCheckingType spellCheckingType;
	
    BOOL _editable;
	
	DTLoupeView *_loupe;
	DTCursorView *_cursor;
	DTTextSelectionView *_selectionView;
	
	DTDragMode _dragMode;
	BOOL _shouldReshowContextMenuAfterHide;
	BOOL _shouldShowContextMenuAfterLoupeHide;
	BOOL _canInteractWithPasteboard;
	
	CGPoint _dragCursorStartMidPoint;
	CGPoint _touchDownPoint;
	NSDictionary *_overrideInsertionAttributes;
	
	UITapGestureRecognizer *tap;
	UILongPressGestureRecognizer *longPressGesture;
	UIPanGestureRecognizer *panGesture;
	
	// overrides
	CGSize _maxImageDisplaySize;
	NSString *_defaultFontFamily;
	NSURL *_baseURL;
	CGFloat _textSizeMultiplier;
}


@property(nonatomic,getter=isEditable) BOOL editable;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property(nonatomic, assign) id<UITextInputDelegate> inputDelegate;
@property (nonatomic, copy) NSDictionary *markedTextStyle;
@property (nonatomic) UITextStorageDirection selectionAffinity;

@property (nonatomic, assign) CGSize maxImageDisplaySize;
@property (nonatomic, copy) NSString *defaultFontFamily;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, assign) CGFloat textSizeMultiplier;


@property (nonatomic, retain) DTCursorView *cursor;

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

@property (nonatomic, assign) BOOL canInteractWithPasteboard;

@end

@interface DTRichTextEditorView (manipulation)

- (DTTextRange *)rangeForWordAtPosition:(DTTextPosition *)position;

- (NSDictionary *)typingAttributesForRange:(UITextRange *)range;
- (void)replaceRange:(UITextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

- (void)toggleBoldInRange:(UITextRange *)range;
- (void)toggleItalicInRange:(UITextRange *)range;
- (void)toggleUnderlineInRange:(UITextRange *)range;

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;
- (void)relayoutText;

- (BOOL)pasteboardHasSuitableContentForPaste;
- (NSString *)plainTextForRange:(UITextRange *)range;

- (NSDictionary *)textDefaults;
- (void)setHTMLString:(NSString *)string;

@end
