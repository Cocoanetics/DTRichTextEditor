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

@protocol DTRichTextEditorViewDelegate;

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
 @name Accessing the Editor Delegate
 */

/**
 An editor view delegate responds to editing-related messages from the editor view. You can use the delegate to track changes to the text itself and to the current selection.
 
 @see DTRichTextEditorViewDelegate
 */
@property (nonatomic, assign) id<DTRichTextEditorViewDelegate> editorViewDelegate;


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


/**
 The DTRichTextEditorViewDelegate protocol defines a set of optional methods you can use to receive editing-related messages for DTRichTextEditorView objects. All of the methods in this protocol are optional. You can use them in situations where you might want to adjust the text being edited (such as in the case of a spell checker program) or modify the intended insertion point.
 */
@protocol DTRichTextEditorViewDelegate <NSObject>

@optional

/**
 @name Responding to Editing Notifications
 */

/**
 Asks the delegate if editing should begin in the specified editor view.
 
 @param editorView The editor view for which editing is about to begin.
 @return YES if an editing session should be initiated; otherwise, NO to disallow editing.
 */
- (BOOL)editorViewShouldBeginEditing:(DTRichTextEditorView *)editorView;

/**
 Tells the delegate that editing of the specified editor view has begun.
 
 @param editorView The editor view in which editing began.
 */
- (void)editorViewDidBeginEditing:(DTRichTextEditorView *)editorView;

/**
 Asks the delegate if editing should stop in the specified editor view.
 
 @param editorView The editor view for which editing is about to end.
 @return YES if editing should stop; otherwise, NO if the editing session should continue
 */
- (BOOL)editorViewShouldEndEditing:(DTRichTextEditorView *)editorView;

/**
 Tells the delegate that editing of the specified text view has ended.
 
 @param editorView The editor view in which editing ended.
 */
- (void)editorViewDidEndEditing:(DTRichTextEditorView *)editorView;

/**
 @name Responding to Text Changes
 */

/**
 Asks the delegate whether the specified DTTextAttachment object should be inserted in the given range.
 
 The delegate can return NO to disallow pasting of text attachments. 
 
 @param editorView The editor view containing the changes.
 @param textAttachment The text attachment to insert.
 @param range The current selection range.  If the length of the range is 0, range reflects the current insertion point.
 @return YES if the text attachment should be inserted, replacing any text or attachments in the selected range.
 */
- (BOOL)editorView:(DTRichTextEditorView *)editorView shouldInsertTextAttachment:(DTTextAttachment *)textAttachment inRange:(NSRange)range;

/**
 Asks the delegate whether the specified text should be replaced in the text view.
 
 @param editorView The editor view containing the changes.
 @param range The current selection range.  If the length of the range is 0, range reflects the current insertion point.  If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character.
 @param text The text to insert.
 @return YES if the old text should be replaced by the new text; NO if the replacement operation should be aborted.
 */
- (BOOL)editorView:(DTRichTextEditorView *)editorView shouldChangeTextInRange:(NSRange)range replacementText:(NSAttributedString *)text;

/**
 Tells the delegate that the text or attributes in the specified editor view were changed by the user
 
 @param editorView The editor view containing the changes.
 */
- (void)editorViewDidChange:(DTRichTextEditorView *)editorView;

/**
 @name Responding to Selection Changes
 */

/**
 Tells the delegate that the text selection changed in the specified editor view.
 
 @param editorView The editor view whose selection changed.
 */
- (void)editorViewDidChangeSelection:(DTRichTextEditorView *)editorView;

@end
