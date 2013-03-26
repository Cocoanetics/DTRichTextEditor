//
//  DTRichTextEditorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTAttributedTextView.h"

@class DTTextRange, DTTextPosition;
@class DTCursorView;
@class DTLoupeView;
@class DTTextSelectionView;
@class DTCSSListStyle;

/**
 DTRichTextEditorView is a subclass of UIScrollView and offers rich text edtiting capabilities. It has a single content view of type DTRichTextEditorContentView which is repsonsible for displaying the rich text.
 */
@interface DTRichTextEditorView : DTAttributedTextView <UITextInputTraits, UITextInput>

/**
 @name Setting Text Defaults
 */

/**
 Override for the maximum image display size. 
 
 This property represents part of the textDefaults. Setting those will set this property and vice versa.
 */
@property (nonatomic, assign) CGSize maxImageDisplaySize;

/**
 Override for the default font family.
 
 This property represents part of the textDefaults. Setting those will set this property and vice versa.
 */
@property (nonatomic, copy) NSString *defaultFontFamily;

/**
 Override for the default font size.
 
 This property represents part of the textDefaults. Setting those will set this property and vice versa.
 */
@property (nonatomic, assign) CGFloat defaultFontSize;

/**
 Override for the base URL.
 
 This property represents part of the textDefaults. Setting those will set this property and vice versa.
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 Override for the text size multiplier.
 
 This property represents part of the textDefaults. Setting those will set this property and vice versa.
 */
@property (nonatomic, assign) CGFloat textSizeMultiplier;

/**
 The default options to be used for text. See the options parameter of <DTHTMLAttributedStringBuilder> for individual options.
 
 If one of these properties is set then it is used instead of the value contained in textDefaults:
 
 - maxImageDisplaySize
 - defaultFontFamily
 - defaultFontSize
 - baseURL;
 - textSizeMultiplier;
 
 NOTE: Changing these defaults does not affect the current `NSAttributedString`. They are used when calling setHTMLString.
 */
@property (nonatomic, retain) NSDictionary *textDefaults;


/**
 @name Accessing Views
 */

/**
 Overrides the `UIResponder` input view to be settable. The inputView is show instead of the system keyboard when input is possible.
 */
@property (retain, readwrite) UIView *inputView;

/**
 Overrides the `UIResponder` input accessory view to be settable. The accessory gets shown riding on top of the inputView when input is possible.
 */
@property (retain, readwrite) UIView *inputAccessoryView;

/**
 @name Modifying Text Content
 */

/**
 Replaces a range of text. The current selection is adapted, too.
 
 This is an overwritten method that accepts either an `NSString` or `NSAttributedString`.
 @param range The text range to replace
 @param text The text for the replacement
 */
- (void)replaceRange:(UITextRange *)range withText:(id)text;


/**
 @name Cursor and Selection
 */

/**
 Scrolls the receiver's content view so that the cursor is visible.
 @param animated If `YES` then the view is scrolled animated. If `NO` it jumps to the scroll position
 */
- (void)scrollCursorVisibleAnimated:(BOOL)animated;

/**
 Changes the current text selection range to the new value. Can optionally be animated.
 @param newTextRange The new text range to select
 @param animated If `YES` then an extension (e.g. to include a full word) is animated
 */
- (void)setSelectedTextRange:(DTTextRange *)newTextRange animated:(BOOL)animated;


/**
 @name Getting Information
 */

/**
 Gets the bounds of the rectangle that encloses the cursor or an envelope around the current selection. Can be used for the target area of a context menu.
 */
- (CGRect)boundsOfCurrentSelection;

/**
 Property to enable copy/paste support. If enabled the user can paste text into DTRichTextEditorView or copy text to the pasteboard.
 */
@property (nonatomic, assign) BOOL canInteractWithPasteboard;

/**
 Specifies that the receiver can be edited. That means that on tapping it it becomes first responder and shows the current input view (keyboard). If it is not editable then dragging the finger over the view highlights entire words and does not show the selection dragging handles.
 */
@property(nonatomic,getter=isEditable) BOOL editable;

/**
 Specifies that the receiver is in an editing state.  That means that the editor is first responder, and an inputView(usually the system keyboard) and cursor are showing. To programmatically enter an editing state, call becomeFirstResponder on the editor object when isEditable = YES(the default).  To programmatically end editing, call resignFirstResponder.
 */
@property (nonatomic, assign, readonly, getter = isEditing) BOOL editing;

/**
 If this property is `YES` then all typed enters are replaced with the Line Feed (LF) character.
 
 @warning This causes all text to end up in a single paragraph and all paragraph-level styles are going to affect all of the text. It therefore severely affects the display performance. We recommend you don't activate this if you don't want spaces between paragraphs but rather set the paragraph spacing to zero via a custom style set via textDefaults.
 */
@property(nonatomic, assign) BOOL replaceParagraphsWithLineFeeds;

/**
 The current attributedText displayed in the receiver
 */
@property (nonatomic, copy) NSAttributedString *attributedText;

@end

