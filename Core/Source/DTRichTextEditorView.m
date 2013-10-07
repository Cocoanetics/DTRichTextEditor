//
//  DTRichTextEditorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DTLoupeView.h"

#import "DTRichTextEditor.h"

#import "DTCoreTextLayoutFrame+DTRichText.h"
#import "DTMutableCoreTextLayoutFrame.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "DTMutableCoreTextLayoutFrame.h"
#import "NSMutableDictionary+DTRichText.h"
#import "DTRichTextEditorView.h"
#import "DTRichTextEditorView+Manipulation.h"
#import "DTDictationPlaceholderView.h"

#import "DTCursorView.h"
#import "DTLoupeView.h"
#import "DTCoreTextLayouter.h"

#import "DTUtils.h"
#import "DTCoreTextFontDescriptor.h"
#import "DTTiledLayerWithoutFade.h"

#import "DTWebArchive.h"
#import "NSAttributedString+DTWebArchive.h"
#import "NSAttributedString+DTRichText.h"
#import "NSAttributedStringRunDelegates.h"
#import "UIPasteboard+DTWebArchive.h"
#import "DTRichTextEditorContentView.h"
#import "DTRichTextEditorView+Manipulation.h"
#import "DTUndoManager.h"
#import "DTHTMLWriter.h"
#import "DTHTMLWriter+DTWebArchive.h"


NSString * const DTRichTextEditorTextDidBeginEditingNotification = @"DTRichTextEditorTextDidBeginEditingNotification";
NSString * const DTRichTextEditorTextDidChangeNotification = @"DTRichTextEditorTextDidChangeNotification";
NSString * const DTRichTextEditorTextDidEndEditingNotification = @"DTRichTextEditorTextDidEndEditingNotification";

static void * DTRichTextEditorAutocorrectionPromptFrameObservation = @"DTRichTextEditorAutocorrectionPromptFrameObservation";

// the modes that can be dragged in
typedef enum
{
	DTDragModeNone = 0,
	DTDragModeLeftHandle,
	DTDragModeRightHandle,
	DTDragModeCursor,
	DTDragModeCursorInsideMarking
} DTDragMode;

// private extensions to the public interface
@interface DTRichTextEditorView () <DTAttributedTextContentViewDelegate, UIGestureRecognizerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, retain) DTTextSelectionView *selectionView;
@property (nonatomic, retain) DTCursorView *cursor;
@property (nonatomic, readwrite) UITextRange *markedTextRange;  // internal property writeable
@property (nonatomic, retain) NSDictionary *overrideInsertionAttributes;
@property (nonatomic, retain) DTMutableCoreTextLayoutFrame *mutableLayoutFrame;
@property (nonatomic, retain) DTUndoManager *undoManager;
@property (nonatomic, assign) BOOL waitingForDictionationResult;
@property (nonatomic, retain) DTDictationPlaceholderView *dictationPlaceholderView;

@property (nonatomic, assign, readwrite, getter = isEditing) BOOL editing; // default is NO, starts up and shuts down editing state
@property (nonatomic, assign) BOOL overrideEditorViewDelegate; // default is NO, used when forcing change in editing state
@property (retain, readwrite) UIView *inputView;

@property (nonatomic, assign) BOOL userIsTyping;  // while user is typing there are no selection range updates to input delegate
@property (nonatomic, assign) BOOL keepCurrentUndoGroup; // to avoid closing an undo group if it is a sub-operation

@property (nonatomic, retain, readonly) NSArray *editorMenuItems;
@property (nonatomic, retain) UIPopoverController *definePopoverController; // used for presenting definitions of a selected term on the iPad

- (void)setDefaultText;
- (void)showContextMenuFromSelection;
- (void)hideContextMenu;

- (CGRect)visibleContentRect;
- (BOOL)selectionIsVisible;
- (void)relayoutText;

@end

@implementation DTRichTextEditorView
{
	// customization options available as properties
	BOOL _editable;
	BOOL _replaceParagraphsWithLineFeeds;
	BOOL _canInteractWithPasteboard;
	BOOL _preservesSelectionOnResignFirstReponder;
	
	UIView *_inputView;
	UIView *_inputAccessoryView;
    
    CGFloat _heightCoveredByKeyboard;
	
	// private stuff
	id<UITextInputTokenizer> tokenizer;
	__unsafe_unretained id<UITextInputDelegate> inputDelegate;
	DTTextRange *_selectedTextRange;
	DTTextRange *_markedTextRange;
	NSDictionary *_markedTextStyle;
	
	UITextStorageDirection _selectionAffinity;
	
	// UITextInputTraits
	UITextAutocapitalizationType autocapitalizationType; // default is UITextAutocapitalizationTypeSentences
	UITextAutocorrectionType autocorrectionType;         // default is UITextAutocorrectionTypeDefault
	BOOL enablesReturnKeyAutomatically;                  // default is NO
	UIKeyboardAppearance keyboardAppearance;             // default is UIKeyboardAppearanceDefault
	UIKeyboardType keyboardType;                         // default is UIKeyboardTypeDefault
	UIReturnKeyType returnKeyType;                       // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
	BOOL secureTextEntry;                                // default is NO
	
	// not enabled, that's new as of iOS5
	//  UITextSpellCheckingType spellCheckingType;
	
	DTCursorView *_cursor;
	DTTextSelectionView *_selectionView;
	
	// internal state
	DTDragMode _dragMode;
	BOOL _shouldReshowContextMenuAfterHide;
	BOOL _shouldShowContextMenuAfterLoupeHide;
    BOOL _shouldShowDragHandlesAfterLoupeHide;
	BOOL _shouldShowContextMenuAfterMovementEnded;
    BOOL _userIsTyping;
	BOOL _keepCurrentUndoGroup;
    BOOL _waitingForDictationResult;
	BOOL _isChangingInputView;
	
    DTDictationPlaceholderView *_dictationPlaceholderView;
	
	CGPoint _dragCursorStartMidPoint;
	CGPoint _touchDownPoint;
	NSDictionary *_overrideInsertionAttributes;
	
	BOOL _contextMenuVisible;
	NSTimeInterval _lastCursorMovementTimestamp;
    CGPoint _lastCursorMovementTouchPoint;
	
	// gesture recognizers
	UITapGestureRecognizer *tapGesture;
	UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *tripleTapGesture;
	UILongPressGestureRecognizer *longPressGesture;
	UIPanGestureRecognizer *panGesture;
	
	// overrides
	CGSize _maxImageDisplaySize;
	NSString *_defaultFontFamily;
	NSURL *_baseURL;
	CGFloat _textSizeMultiplier;
	
	NSDictionary *_textDefaults;
    
    // tracking of content insets
    UIEdgeInsets _userSetContentInsets;
	UIEdgeInsets _userSetScrollIndicatorInsets;
    BOOL _shouldNotRecordChangedContentInsets;
	
	// the undo manager
	DTUndoManager *_undoManager;
    
    // editor view delegate respondsTo cache flags
    struct {
        // Editing State
        unsigned int delegateShouldBeginEditing:1;
        unsigned int delegateDidBeginEditing:1;
        unsigned int delegateShouldEndEditing:1;
        unsigned int delegateDidEndEditing:1;
        
        // Text and Selection Changes
        unsigned int delegateShouldChangeTextInRangeReplacementText:1;
        unsigned int delegateWillPasteTextInRange:1;
        unsigned int delegateDidChange:1;
        unsigned int delegateDidChangeSelection:1;
        
        // Editing Menu Items
        unsigned int delegateMenuItems:1;
        unsigned int delegateCanPerformActionsWithSender:1;
    } _editorViewDelegateFlags;
    
    // Use to disallow canPerformAction: to proceed up the responder chain (-nextResponder)
    BOOL _stopResponderChain;
	
	UIView *_autocorrectionPromptView;
}

#pragma mark -
#pragma mark Initialization

+(void)initialize
{
#ifdef TIMEBOMB
#warning Timebomb enabled
	// TIMEBOMB define is seconds since 1970 when the thing should stop working
	NSTimeInterval expirationTimestamp = TIMEBOMB;
	NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:expirationTimestamp];
	
	// date formatter for output
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setTimeStyle:NSDateFormatterNoStyle];
	[df setDateStyle:NSDateFormatterMediumStyle];
	
	NSDate *now = [NSDate date];
	if ([now compare:expirationDate] == NSOrderedDescending)
	{
		NSLog(@"ERROR: This demo expired on %@", [df stringFromDate:expirationDate]);
		exit(1);
	}
	else
	{
		NSLog(@"WARNING: This demo expires on %@", [df stringFromDate:expirationDate]);
	}
#endif
	
}

- (void)setDefaults
{
	_canInteractWithPasteboard = YES;
    
    // text defaults
    _textSizeMultiplier = 1.0;
    _defaultFontSize = 12.0f;
    _defaultFontFamily = @"Times New Roman";
	
	// --- text input
    self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.enablesReturnKeyAutomatically = NO;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.secureTextEntry = NO;
    self.selectionAffinity = UITextStorageDirectionForward;
	//   self.spellCheckingType = UITextSpellCheckingTypeYes;
	
	// --- look
    self.backgroundColor = [UIColor whiteColor];
	self.editable = YES;
    self.selectionAffinity = UITextStorageDirectionForward;
	self.userInteractionEnabled = YES; 	// for autocorrection candidate view
    self.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
	
	// --- gestures
    if (!tripleTapGesture)
    {
        tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTap:)];
        tripleTapGesture.delegate = self;
        tripleTapGesture.numberOfTapsRequired = 3;
        tripleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tripleTapGesture];
    }
    
	if (!doubleTapGesture)
	{
		doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		doubleTapGesture.delegate = self;
		doubleTapGesture.numberOfTapsRequired = 2;
		doubleTapGesture.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:doubleTapGesture];
	}
	
	if (!tapGesture)
	{
		tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		tapGesture.delegate = self;
		tapGesture.numberOfTapsRequired = 1;
		tapGesture.numberOfTouchesRequired = 1;
		[tapGesture requireGestureRecognizerToFail:doubleTapGesture];
		[self addGestureRecognizer:tapGesture];
	}
	
	if (!panGesture)
	{
		panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragHandle:)];
		panGesture.delegate = self;
		[self addGestureRecognizer:panGesture];
	}
	
	if (!longPressGesture)
	{
		longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
		longPressGesture.delegate = self;
		[self addGestureRecognizer:longPressGesture];
	}
	
	// --- notifications
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(cursorDidBlink:) name:DTCursorViewDidBlink object:nil];
	[center addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
	[center addObserver:self selector:@selector(loupeDidHide:) name:DTLoupeDidHide object:nil];
	[center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// style for displaying marked text
	self.markedTextStyle = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor greenColor], UITextInputTextColorKey, nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setDefaults];
    }
    
    return self;
}

- (void)dealloc
{
    self.editorViewDelegate = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	[DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
	
    [super awakeFromNib];
    
    [self setDefaults];
}

- (void)layoutSubviews
{
	if (![self.attributedTextContentView.layoutFrame.attributedStringFragment length])
	{
		[self setDefaultText];
	}
	
	// this also layouts the content View
	[super layoutSubviews];
    
    [_selectionView layoutSubviewsInRect:self.bounds];
	
	if (self.isDragging || self.decelerating)
	{
		DTLoupeView *loupe = [DTLoupeView sharedLoupe];
		
		if ([loupe isShowing] && loupe.style == DTLoupeStyleCircle)
		{
			loupe.seeThroughMode = YES;
		}
		
		if ([[UIMenuController sharedMenuController] isMenuVisible])
		{
			if (![_selectedTextRange isEmpty])
			{
				_shouldShowContextMenuAfterMovementEnded = YES;
			}
			
			[self hideContextMenu];
		}
		
		SEL selector = @selector(movementDidEnd);
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
		[self performSelector:selector withObject:nil afterDelay:0.5];
	}
}

- (void)setDefaultText
{
	// default needs to be just a \n, the style attributes of that are used for
	// all subsequent insertions
	[self setHTMLString:@"<p></p>"];
}

// we want our special content view that uses mutable layout frames
- (Class)classForContentView
{
	return [DTRichTextEditorContentView class];
}

#pragma mark - Menu

- (void)hideContextMenu
{
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	if ([menuController isMenuVisible])
	{
		[menuController setMenuVisible:NO animated:YES];
	}
	
	_contextMenuVisible = NO;
}

- (void)showContextMenuFromSelection
{
    // Bail out if selection isn't visible
	if (![self selectionIsVisible])
	{
		// don't show it
		return;
	}
	
    // Attempt to become first responder if needed for context menu
	if (!self.isFirstResponder)
	{
		[self becomeFirstResponder];
        
        if (!self.isFirstResponder)
            return;
	}
    
    // Display the context menu
    _contextMenuVisible = YES;
    CGRect targetRect = [self visibleBoundsOfCurrentSelection];
    
    // Present the menu
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	[menuController setTargetRect:targetRect inView:self];
	[menuController setMenuVisible:YES animated:YES];
}

- (void)menuDidHide:(NSNotification *)notification
{
	if (_shouldReshowContextMenuAfterHide)
	{
		_shouldReshowContextMenuAfterHide = NO;
		
		[self performSelector:@selector(showContextMenuFromSelection) withObject:nil afterDelay:0.10];
	}
}

- (void)loupeDidHide:(NSNotification *)notification
{
	if (_shouldShowContextMenuAfterLoupeHide)
	{
		_shouldShowContextMenuAfterLoupeHide = NO;
		
		[self performSelector:@selector(showContextMenuFromSelection) withObject:nil afterDelay:0.10];
	}
    
    if (_shouldShowDragHandlesAfterLoupeHide)
    {
        _shouldShowDragHandlesAfterLoupeHide = NO;
        
        _selectionView.dragHandlesVisible = YES;
    }
}

- (void)movementDidEnd
{
	if (_shouldShowContextMenuAfterMovementEnded || _contextMenuVisible)
	{
		_shouldShowContextMenuAfterMovementEnded = NO;
		[self showContextMenuFromSelection];
	}
}

#pragma mark Custom Selection/Marking/Cursor
- (void)_scrollRectInContentViewToVisible:(CGRect)rect animated:(BOOL)animated
{
    UIEdgeInsets reverseInsets = self.attributedTextContentView.edgeInsets;
	reverseInsets.top *= -1.0;
	reverseInsets.bottom *= -1.0;
	reverseInsets.left *= -1.0;
	reverseInsets.right *= -1.0;
	
	CGRect scrollToRect = UIEdgeInsetsInsetRect(rect, reverseInsets);
	
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		
		// this prevents multiple scrolling to same position
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
    // make sure that the target scroll rect is inside the content view
    scrollToRect = CGRectIntersection(scrollToRect, self.attributedTextContentView.bounds);
    
	[self scrollRectToVisible:scrollToRect animated:NO];
	
	if (animated)
	{
		[UIView commitAnimations];
	}
}

- (void)scrollCursorVisibleAnimated:(BOOL)animated
{
    if (!self.isEditing)
        return;
	
	CGRect cursorFrame = [self caretRectForPosition:self.selectedTextRange.start];
    cursorFrame.size.width = 3.0;
	
    [self _scrollRectInContentViewToVisible:cursorFrame animated:animated];
}

- (void)updateCursorAnimated:(BOOL)animated
{
	// no selection
    if ((self.selectedTextRange == nil) || (self.isEditable && !self.isEditing) || !self.isFirstResponder)
	{
		// remove cursor
		[_cursor removeFromSuperview];
		
		// remove selection
		_selectionView.selectionRectangles = nil;
		_selectionView.dragHandlesVisible = NO;
		
		return;
	}
	
	// single cursor
	if ([_selectedTextRange isEmpty])
	{
        // show as a single caret
		_selectionView.dragHandlesVisible = NO;
        
		DTTextPosition *position = (id)self.selectedTextRange.start;
		CGRect cursorFrame = [self caretRectForPosition:position];
		cursorFrame.size.width = 3.0;
		
        if (!CGRectEqualToRect(cursorFrame, self.cursor.frame))
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.cursor.frame = cursorFrame;
            [CATransaction commit];
        }
		
		if (!_cursor.superview)
		{
			[self addSubview:_cursor];
		}
		
		[self scrollCursorVisibleAnimated:YES];
	}
	else
	{
        // show as a blue selection range
		self.selectionView.style = DTTextSelectionStyleSelection;
        self.selectionView.dragHandlesVisible = YES;
		NSArray *textSelectionRects = [self selectionRectsForRange:_selectedTextRange];
		[_selectionView setSelectionRectangles:textSelectionRects animated:animated];
		
		// no cursor
		[_cursor removeFromSuperview];
        
        if ([textSelectionRects count])
        {
            // scroll the currently dragged handle to be visible
            
            if (_dragMode == DTDragModeLeftHandle)
            {
                DTTextSelectionRect *selectionRect = [textSelectionRects objectAtIndex:0];
                [self _scrollRectInContentViewToVisible:selectionRect.rect animated:YES];
            }
            else if (_dragMode == DTDragModeRightHandle)
            {
                DTTextSelectionRect *selectionRect = [textSelectionRects lastObject];
                [self _scrollRectInContentViewToVisible:selectionRect.rect animated:YES];
            }
        }
        
		return;
	}
	
	if (_markedTextRange)
	{
		self.selectionView.style = DTTextSelectionStyleMarking;
		
		NSArray *textSelectionRects = [self selectionRectsForRange:_markedTextRange];
		_selectionView.selectionRectangles = textSelectionRects;
		
		_selectionView.dragHandlesVisible = NO;
	}
	else
	{
		_selectionView.selectionRectangles = nil;
	}
}

// in edit mode or if not firstResponder we select words
- (void)selectWordAtPositionClosestToLocation:(CGPoint)location
{
	UITextPosition *position = (id)[self closestPositionToPoint:location];
	UITextRange *wordRange = [self textRangeOfWordAtPosition:position];
	self.selectedTextRange = wordRange;
}


- (BOOL)moveCursorToPositionClosestToLocation:(CGPoint)location
{
	BOOL didMove = NO;
	
	DTTextRange *constrainingRange = nil;
	
	if ([_markedTextRange length] && [self selectionIsVisible])
	{
        constrainingRange = _markedTextRange;
	}
	else if ([_selectedTextRange length] && [self selectionIsVisible])
	{
        constrainingRange =_selectedTextRange;
	}
	
	DTTextPosition *position = (id)[self closestPositionToPoint:location withinRange:constrainingRange];
    
    // Move if there is a selection or if the position is not the same as the cursor
    if (![_selectedTextRange isEmpty] || ![(DTTextPosition *)_selectedTextRange.start isEqual:position])
    {
        didMove = YES;
        
        self.selectedTextRange = [self textRangeFromPosition:position toPosition:position];
        
        // begins a new typing undo group
        DTUndoManager *undoManager = self.undoManager;
        [undoManager closeAllOpenGroups];
    }
	
	return didMove;
}


- (void)presentLoupeWithTouchPoint:(CGPoint)touchPoint
{
	_touchDownPoint = touchPoint;
	
	DTLoupeView *loupe = [DTLoupeView sharedLoupe];
	loupe.targetView = self.attributedTextContentView;
	
	if (_selectionView.dragHandlesVisible)
	{
		if (CGRectContainsPoint(_selectionView.dragHandleLeft.frame, touchPoint))
		{
			_dragMode = DTDragModeLeftHandle;
		}
		else if (CGRectContainsPoint(_selectionView.dragHandleRight.frame, touchPoint))
		{
			_dragMode = DTDragModeRightHandle;
		}
		else
		{
			_dragMode = DTDragModeCursor;
		}
	}
	else
	{
		if (_markedTextRange)
		{
			_dragMode = DTDragModeCursorInsideMarking;
		}
		else
		{
			_dragMode = DTDragModeCursor;
		}
	}
	
	if (_dragMode == DTDragModeLeftHandle)
	{
		CGPoint loupeStartPoint;
		CGRect rect = [_selectionView beginCaretRect];
        
        // avoid presenting if there is no selection
        if (CGRectIsNull(rect))
        {
            return;
        }
        
		loupeStartPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
		
		_dragCursorStartMidPoint = CGRectCenter(rect);
		
		loupe.style = DTLoupeStyleRectangleWithArrow;
		loupe.magnification = 0.5;
		loupe.touchPoint = loupeStartPoint;
		[loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	if (_dragMode == DTDragModeRightHandle)
	{
		CGPoint loupeStartPoint;
		
		CGRect rect = [_selectionView endCaretRect];
        
        // avoid presenting if there is no selection
        if (CGRectIsNull(rect))
        {
            return;
        }
		
		loupeStartPoint = CGRectCenter(rect);
		_dragCursorStartMidPoint = CGRectCenter(rect);
		
		
		loupe.style = DTLoupeStyleRectangleWithArrow;
		loupe.magnification = 0.5;
		loupe.touchPoint = loupeStartPoint;
		loupe.touchPointOffset = CGSizeMake(0, rect.origin.y - _dragCursorStartMidPoint.y);
		[loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	if (_dragMode == DTDragModeCursorInsideMarking)
	{
		loupe.style = DTLoupeStyleRectangleWithArrow;
		loupe.magnification = 0.5;
		
		CGPoint loupeStartPoint = CGRectCenter(_cursor.frame);
		
		loupe.touchPoint = loupeStartPoint;
		[loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	// normal round loupe
	loupe.style = DTLoupeStyleCircle;
	loupe.magnification = 1.2;
	
	if (self.editable)
	{
		[self moveCursorToPositionClosestToLocation:touchPoint];
	}
	else
	{
		[self selectWordAtPositionClosestToLocation:touchPoint];
		_selectionView.dragHandlesVisible = NO;
	}
	
	loupe.touchPoint = touchPoint;
	[loupe presentLoupeFromLocation:touchPoint];
}

- (void)moveLoupeWithTouchPoint:(CGPoint)touchPoint
{
	DTLoupeView *loupe = [DTLoupeView sharedLoupe];
	
	if (_dragMode == DTDragModeCursor)
	{
		CGRect visibleArea = [self visibleContentRect];
		
		// switch to see-through mode outside of visible content area
		if (CGRectContainsPoint(visibleArea, touchPoint))
		{
			loupe.seeThroughMode = NO;
            loupe.touchPoint = touchPoint;
		}
		else
		{
			loupe.seeThroughMode = YES;
			
			// restrict bottom of loupe frame to visible area
            CGPoint restrictedTouchPoint = touchPoint;
            restrictedTouchPoint.y = MIN(touchPoint.y, CGRectGetMaxY(visibleArea)+3);
            
			loupe.touchPoint = restrictedTouchPoint;
		}
		
		[self hideContextMenu];
		
		if (self.isEditable && self.isEditing)
		{
			[self moveCursorToPositionClosestToLocation:touchPoint];
		}
		else
		{
			[self selectWordAtPositionClosestToLocation:touchPoint];
            _selectionView.dragHandlesVisible = NO;
		}
		return;
	}
	
	if (_dragMode == DTDragModeCursorInsideMarking)
	{
		[self moveCursorToPositionClosestToLocation:touchPoint];
		
		loupe.touchPoint = CGRectCenter(_cursor.frame);
		loupe.seeThroughMode = NO;
		
		[self hideContextMenu];
		
		return;
	}
	
	CGPoint translation = touchPoint;
	translation.x -= _touchDownPoint.x;
	translation.y -= _touchDownPoint.y;
	
	// get current mid point
	CGPoint movedMidPoint = _dragCursorStartMidPoint;
	movedMidPoint.x += translation.x;
	movedMidPoint.y += translation.y;
	
	DTTextPosition *position = (DTTextPosition *)[self closestPositionToPoint:movedMidPoint];
	
	DTTextPosition *startPosition = (DTTextPosition *)_selectedTextRange.start;
	DTTextPosition *endPosition = (DTTextPosition *)_selectedTextRange.end;
	
	DTTextRange *newRange = nil;
	
	if (_dragMode == DTDragModeLeftHandle)
	{
		if ([position compare:endPosition]==NSOrderedAscending)
		{
			newRange = [DTTextRange textRangeFromStart:position toEnd:endPosition];
		}
	}
	else if (_dragMode == DTDragModeRightHandle)
	{
		if ([startPosition compare:position]==NSOrderedAscending)
		{
			newRange = [DTTextRange textRangeFromStart:startPosition toEnd:position];
		}
	}
	
	if (newRange && ![newRange isEqual:_selectedTextRange])
	{
		self.selectedTextRange = newRange;
	}
	
	if (_dragMode == DTDragModeLeftHandle)
	{
		CGRect rect = [_selectionView beginCaretRect];
		
		CGFloat zoom =  25.0f / rect.size.height;
		[DTLoupeView sharedLoupe].magnification = zoom;
		
		CGPoint point = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
		loupe.touchPoint = point;
	}
	else if (_dragMode == DTDragModeRightHandle)
	{
		CGRect rect = [_selectionView endCaretRect];
		CGFloat zoom = 25.0f / rect.size.height;
		[DTLoupeView sharedLoupe].magnification = zoom;
		
		CGPoint point = CGRectCenter(rect);
		loupe.touchPoint = point;
	}
}

- (void)dismissLoupeWithTouchPoint:(CGPoint)touchPoint
{
	DTLoupeView *loupe = [DTLoupeView sharedLoupe];
	
	if (_dragMode == DTDragModeCursor || _dragMode == DTDragModeCursorInsideMarking)
	{
		if (self.editable)
		{
			if (self.isEditing)
			{
				[loupe dismissLoupeTowardsLocation:self.cursor.center];
				_cursor.state = DTCursorStateBlinking;
			}
			else
			{
				[loupe dismissLoupeTowardsLocation:touchPoint];
			}
		}
		else
		{
			CGRect rect = [_selectionView beginCaretRect];
			CGPoint point = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
			[loupe dismissLoupeTowardsLocation:point];
		}
	}
	else if (_dragMode == DTDragModeLeftHandle)
	{
		CGRect rect = [_selectionView beginCaretRect];
		CGPoint point = CGRectCenter(rect);
		_shouldShowContextMenuAfterLoupeHide = YES;
		[loupe dismissLoupeTowardsLocation:point];
	}
	else if (_dragMode == DTDragModeRightHandle)
	{
		_shouldShowContextMenuAfterLoupeHide = YES;
		CGRect rect = [_selectionView endCaretRect];
		CGPoint point = CGRectCenter(rect);
		[loupe dismissLoupeTowardsLocation:point];
	}
	
	_dragMode = DTDragModeNone;
}

- (void)extendSelectionToIncludeWordInDirection:(UITextStorageDirection)direction
{
    if (direction == UITextStorageDirectionForward)
    {
        if ([[self tokenizer] isPosition:_selectedTextRange.end atBoundary:UITextGranularityWord inDirection:UITextStorageDirectionForward])
        {
            // already at end of word
            return;
        }
        
        
        UITextPosition *newEnd = (id)[[self tokenizer] positionFromPosition:_selectedTextRange.end
																 toBoundary:UITextGranularityWord
																inDirection:UITextStorageDirectionForward];
        
        if (!newEnd)
        {
            // no word boundary after position
            return;
        }
        
        DTTextRange *newRange = [DTTextRange textRangeFromStart:_selectedTextRange.start toEnd:newEnd];
        
        [self setSelectedTextRange:newRange animated:YES];
    }
    else if (direction == UITextStorageDirectionBackward)
    {
        if ([[self tokenizer] isPosition:_selectedTextRange.start atBoundary:UITextGranularityWord inDirection:UITextStorageDirectionBackward])
        {
            // already at end of word
            return;
        }
        
        
        UITextPosition *newStart = (id)[[self tokenizer] positionFromPosition:_selectedTextRange.start
																   toBoundary:UITextGranularityWord
																  inDirection:UITextStorageDirectionBackward];
        
        if (!newStart)
        {
            // no word boundary before position
            return;
        }
        
        DTTextRange *newRange = [DTTextRange textRangeFromStart:newStart toEnd:_selectedTextRange.end];
        
        [self setSelectedTextRange:newRange animated:YES];
    }
}

- (CGRect)boundsOfCurrentSelection
{
	CGRect targetRect = CGRectZero;
	
	if ([_selectedTextRange length])
	{
		targetRect = [_selectionView selectionEnvelope];
	}
	else if (self.isEditing)
	{
		targetRect = self.cursor.frame;
	}
	
	return targetRect;
}

- (CGRect)visibleBoundsOfCurrentSelection
{
    CGRect targetRect = [self boundsOfCurrentSelection];
    
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
    targetRect = CGRectIntersection(targetRect, visibleRect);
    
    return targetRect;
}

#pragma mark Notifications

- (void)cursorDidBlink:(NSNotification *)notification
{
	DTLoupeView *loupe = [DTLoupeView sharedLoupe];
	
	// update loupe magnified image to show changed cursor
	if ([loupe isShowing])
	{
		[loupe setNeedsDisplay];
	}
}

- (void)keyboardDidShow:(NSNotification *)notification
{
	// keyboard frame is in window coordinates
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// convert own frame to window coordinates, frame is in superview's coordinates
	CGRect ownFrame = [self.window convertRect:self.frame fromView:self.superview];
	
	// calculate the area of own frame that is covered by keyboard
	CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
	
	// now this might be rotated, so convert it back
	coveredFrame = [self.window convertRect:coveredFrame toView:self.superview];
    
    _heightCoveredByKeyboard = coveredFrame.size.height;
	
	// if we were changing then this is done now
	_isChangingInputView = NO;
	
	[self _updateContentInsetForKeyboardAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (_isChangingInputView)
	{
		return;
	}
	
    _heightCoveredByKeyboard = 0;
	
	[self _updateContentInsetForKeyboardAnimated:YES];
}

#pragma mark - Autocorrection Prompt

- (void)_updateContentInsetForKeyboardNonAnimated
{
	[self _updateContentInsetForKeyboardAnimated:YES];
}

- (void)_updateContentInsetForKeyboardAnimated:(BOOL)animated
{
	UIEdgeInsets contentInset = UIEdgeInsetsMake(_userSetContentInsets.top, _userSetContentInsets.left, _heightCoveredByKeyboard + _userSetContentInsets.bottom, _userSetContentInsets.right);
	
	if (_autocorrectionPromptView)
	{
		UITextPosition *downPosition = [self positionFromPosition:self.selectedTextRange.end inDirection:UITextLayoutDirectionDown offset:1];
		
		if (!downPosition)
		{
			contentInset.bottom += 40;
		}
	}
	
	if (UIEdgeInsetsEqualToEdgeInsets(contentInset, self.contentInset))
	{
		return;
	}
	
	void (^block)() = ^{
		// set inset to make up for covered array at bottom
		_shouldNotRecordChangedContentInsets = YES;
		
		self.contentInset = contentInset;
		self.scrollIndicatorInsets = contentInset;
		
		_shouldNotRecordChangedContentInsets = NO;
	};
	
	if (animated)
	{
		[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:block
						 completion:^(BOOL finished) {
							 
							 [self scrollCursorVisibleAnimated:YES];
						 }];
	}
	else
	{
		block();
		
		// not animated to avoid artifacting on the prompt
		[self scrollCursorVisibleAnimated:NO];
	}
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
	// Bail out if not recognized
	if (gesture.state != UIGestureRecognizerStateRecognized)
	{
		return;
	}
	
	// If not editable, simple resign first responder (hides context menu, cursors, and selections if showing)
	if (!self.isEditable)
	{
		[self resignFirstResponder];
		return;
	}
	
	// get touch point here, later it might get corrupted by becoming first reponder
	CGPoint touchPoint = [gesture locationInView:self.attributedTextContentView];
	
	// If not editing, attempt to start editing
	BOOL wasEditing = self.isEditing;
	_cursor.state = DTCursorStateBlinking;
	
	if (!self.isFirstResponder)
	{
		[self becomeFirstResponder];
		
		// Bail out if we couldn't start editing (This may occur if editorViewShouldBeginEditing: returns NO)
		if (!self.isEditing)
		{
			return;
		}
	}
	
	// Update selection.  Text input system steals taps inside of marked text so if we receive a tap, we end multi-stage text input.
	[self.inputDelegate selectionWillChange:self];
	
	BOOL hadMarkedText = (self.markedTextRange != nil);
	self.markedTextRange = nil;
	
	DTTextPosition *touchPosition = (DTTextPosition *)[self closestPositionToPoint:touchPoint];
	DTTextRange *touchRange = [DTTextRange textRangeFromStart:touchPosition toEnd:touchPosition];
	
	if ([self.selectedTextRange isEqual:touchRange])
	{
		[self updateCursorAnimated:NO];
		
		if ([[UIMenuController sharedMenuController] isMenuVisible])
		{
			[self hideContextMenu];
		}
		else if (wasEditing && !hadMarkedText)
		{
			[self showContextMenuFromSelection];
		}
	}
	else
	{
		self.selectedTextRange = touchRange;
		
		if (self.isEditing)
		{
			// begins a new typing undo group
			DTUndoManager *undoManager = self.undoManager;
			[undoManager closeAllOpenGroups];
		}
	}
	
	[self.inputDelegate selectionDidChange:self];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
	// Bail out if not recognized
	if (gesture.state != UIGestureRecognizerStateRecognized)
	{
		return;
	}
	
	// get the touch point now, because becoming first responder might change the position
	CGPoint touchPoint = [gesture locationInView:self.attributedTextContentView];
	
	// Attempt to become first responder (for selection, menu, possibly editing)
	if (!self.isFirstResponder)
	{
		[self becomeFirstResponder];
		
		// Bail out if we couldn't become first responder
		if (!self.isEditable && !self.isFirstResponder)
		{
			return;
		}
		
		// Bail out if we couldn't start editing but we're editable (This may occur if editorViewShouldBeginEditing: returns NO)
		if (self.isEditable && !self.isEditing)
		{
			return;
		}
	}
	
	// Select a word closest to the touchPoint
	[self.inputDelegate selectionWillChange:self];
	
	UITextPosition *position = (id)[self closestPositionToPoint:touchPoint withinRange:nil];
	UITextRange *wordRange = [self textRangeOfWordAtPosition:position];
	
	// Bail out if there isn't a word range or if we are editing and it's the same as the current word range
	if (wordRange == nil || (self.isEditing && [self.selectedTextRange isEqual:wordRange]))
		return;
	
	// Text input system steals taps inside of marked text so if we receive a tap, we end multi-stage text input.
	self.markedTextRange = nil;
	self.selectionView.dragHandlesVisible = YES;
	
	[self hideContextMenu];
	
	self.selectedTextRange = wordRange;
	
	[self showContextMenuFromSelection];
	
	if (self.isEditing)
	{
		// begins a new typing undo group
		DTUndoManager *undoManager = self.undoManager;
		[undoManager closeAllOpenGroups];
	}
	
	[self.inputDelegate selectionDidChange:self];
}

- (void)handleTripleTap:(UITapGestureRecognizer *)gesture
{
	// Bail out if not recognized
	if (gesture.state != UIGestureRecognizerStateRecognized)
	{
		return;
	}
	
	// get the touch point now, because becoming first responder might change the position
	CGPoint touchPoint = [gesture locationInView:self.attributedTextContentView];
	
	// Attempt to become first responder (for selection, menu, possibly editing)
	if (!self.isFirstResponder)
	{
		[self becomeFirstResponder];
		
		// Bail out if we couldn't become first responder
		if (!self.isEditable && !self.isFirstResponder)
		{
			return;
		}
		
		// Bail out if we couldn't start editing but we're editable (This may occur if editorViewShouldBeginEditing: returns NO)
		if (self.isEditable && !self.isEditing)
		{
			return;
		}
	}
	
	// Select a paragraph containing the touchPoint
	UITextPosition *position = (id)[self closestPositionToPoint:touchPoint withinRange:nil];
	UITextRange *textRange = [DTTextRange textRangeFromStart:position toEnd:position];
	textRange = [self textRangeOfParagraphsContainingRange:textRange];
	
	// Bail out if there isn't a paragraph range or if we are editing and it's the same as the current selected range
	if (textRange == nil || (self.isEditing && [self.selectedTextRange isEqual:textRange]))
		return;
	
	self.selectionView.dragHandlesVisible = YES;
	
	[self hideContextMenu];
	
	self.selectedTextRange = textRange;
	
	[self showContextMenuFromSelection];
	
	if (self.isEditing)
	{
		// begins a new typing undo group
		DTUndoManager *undoManager = self.undoManager;
		[undoManager closeAllOpenGroups];
	}
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
	CGPoint touchPoint = [gesture locationInView:self.attributedTextContentView];
	
	switch (gesture.state)
	{
        case UIGestureRecognizerStatePossible:
        {
            break;
        }
            
		case UIGestureRecognizerStateBegan:
		{
            // If we get here during multi-stage input we need to cancel it because selectionChanged notifications won't update the text system appropriately.  Text system steals touches inside of marked text.
            if (self.markedTextRange)
            {
                [self.inputDelegate selectionWillChange:self];
                self.markedTextRange = nil;
                [self.inputDelegate selectionDidChange:self];
            }
            
            // wrap long press/drag handles in calls to the input delegate because the intermediate selection changes are not important to editing
            [self _inputDelegateSelectionDidChange];
            
			[self presentLoupeWithTouchPoint:touchPoint];
			_cursor.state = DTCursorStateStatic;
            
            // become first responder to bring up editing and show the cursor
            if (!self.isFirstResponder)
            {
                [self becomeFirstResponder];
            }
			
			// begins a new typing undo group
			DTUndoManager *undoManager = self.undoManager;
			[undoManager closeAllOpenGroups];
            
            break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
            if (fabs(touchPoint.x - _lastCursorMovementTouchPoint.x) > 1.0)
                _lastCursorMovementTimestamp = [NSDate timeIntervalSinceReferenceDate];
            
            _lastCursorMovementTouchPoint = touchPoint;
            
			[self moveLoupeWithTouchPoint:touchPoint];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			if (_dragMode != DTDragModeCursorInsideMarking)
			{
                NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - _lastCursorMovementTimestamp;
                
                if (delta < 0.25)
                {
                    if (_dragMode == DTDragModeLeftHandle)
                    {
                        [self extendSelectionToIncludeWordInDirection:UITextStorageDirectionBackward];
                    }
                    else if (_dragMode == DTDragModeRightHandle)
                    {
                        [self extendSelectionToIncludeWordInDirection:UITextStorageDirectionForward];
                    }
                }
			}
		}
			
		case UIGestureRecognizerStateCancelled:
		{
            _shouldShowContextMenuAfterLoupeHide = YES;
            _shouldShowDragHandlesAfterLoupeHide = YES;
            
            // If we were dragging around the circle loupe, notify delegate of the final cursor selectedTextRange
            if (_dragMode == DTDragModeCursor || _dragMode == DTDragModeCursorInsideMarking)
            {
                [self _editorViewDelegateDidChangeSelection];
            }
            
            // Dismissing will set _dragMode to DTDragModeNone
			[self dismissLoupeWithTouchPoint:touchPoint];
			
            // Notify that long press/drag handles has concluded and selection may be changed
            [self _inputDelegateSelectionDidChange];
            
            break;
		}
            
        case UIGestureRecognizerStateFailed:
        {
            break;
        }
	}
}


- (void)handleDragHandle:(UIPanGestureRecognizer *)gesture
{
	CGPoint touchPoint = [gesture locationInView:self.attributedTextContentView];
	
	switch (gesture.state)
	{
        case UIGestureRecognizerStatePossible:
        {
            break;
        }
            
		case UIGestureRecognizerStateBegan:
		{
            // wrap long press/drag handles in calls to the input delegate because the intermediate selection changes are not important to editing
            [self _inputDelegateSelectionWillChange];
			
            
			[self presentLoupeWithTouchPoint:touchPoint];
			
			[self hideContextMenu];
			
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
            if (fabs(touchPoint.x - _lastCursorMovementTouchPoint.x) > 1.0)
                _lastCursorMovementTimestamp = [NSDate timeIntervalSinceReferenceDate];
            
            _lastCursorMovementTouchPoint = touchPoint;
            
            [self moveLoupeWithTouchPoint:touchPoint];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
            NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - _lastCursorMovementTimestamp;
			
            if (delta < 0.25)
            {
                if (_dragMode == DTDragModeLeftHandle)
                {
                    [self extendSelectionToIncludeWordInDirection:UITextStorageDirectionBackward];
                }
                else if (_dragMode == DTDragModeRightHandle)
                {
                    [self extendSelectionToIncludeWordInDirection:UITextStorageDirectionForward];
                }
            }
		}
            
		case UIGestureRecognizerStateCancelled:
		{
            _shouldShowContextMenuAfterLoupeHide = YES;
            _shouldShowDragHandlesAfterLoupeHide = YES;
            
			[self dismissLoupeWithTouchPoint:touchPoint];
			
            // Notify that long press/drag handles has concluded and selection may be changed
            [self _inputDelegateSelectionDidChange];
			
			break;
		}
            
        case UIGestureRecognizerStateFailed:
        {
            break;
        }
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	CGPoint touchPoint = [touch locationInView:self];
	
	// ignore touches on views that UITextInput adds
	// those are added to self, user custom views are subviews of contentView
	UIView *hitView = [self hitTest:touchPoint withEvent:nil];
	
	if (hitView.superview == self && hitView != self.attributedTextContentView)
	{
		return NO;
	}
	
	if (gestureRecognizer == panGesture)
	{
		if (![_selectionView dragHandlesVisible])
		{
			return NO;
		}
		
		if (CGRectContainsPoint(_selectionView.dragHandleLeft.frame, touchPoint))
		{
			_dragMode = DTDragModeLeftHandle;
		}
		else if (CGRectContainsPoint(_selectionView.dragHandleRight.frame, touchPoint))
		{
			_dragMode = DTDragModeRightHandle;
		}
		
		
		if (_dragMode == DTDragModeLeftHandle || _dragMode == DTDragModeRightHandle)
		{
			return YES;
		}
		else
		{
			return NO;
		}
	}
	
	return YES;
}


#pragma mark - Editor Delegate

@synthesize editorViewDelegate = _editorViewDelegate;

- (id<DTRichTextEditorViewDelegate>)editorViewDelegate
{
    return _editorViewDelegate;
}

- (void)setEditorViewDelegate:(id<DTRichTextEditorViewDelegate>)editorViewDelegate
{
    _editorViewDelegate = editorViewDelegate;
    
    _editorViewDelegateFlags.delegateShouldBeginEditing = [editorViewDelegate respondsToSelector:@selector(editorViewShouldBeginEditing:)];
    _editorViewDelegateFlags.delegateDidBeginEditing = [editorViewDelegate respondsToSelector:@selector(editorViewDidBeginEditing:)];
    _editorViewDelegateFlags.delegateShouldEndEditing = [editorViewDelegate respondsToSelector:@selector(editorViewShouldEndEditing:)];
    _editorViewDelegateFlags.delegateDidEndEditing = [editorViewDelegate respondsToSelector:@selector(editorViewDidEndEditing:)];
    _editorViewDelegateFlags.delegateShouldChangeTextInRangeReplacementText = [editorViewDelegate respondsToSelector:@selector(editorView:shouldChangeTextInRange:replacementText:)];
    _editorViewDelegateFlags.delegateWillPasteTextInRange = [editorViewDelegate respondsToSelector:@selector(editorView:willPasteText:inRange:)];
    _editorViewDelegateFlags.delegateDidChange = [editorViewDelegate respondsToSelector:@selector(editorViewDidChange:)];
    _editorViewDelegateFlags.delegateDidChangeSelection = [editorViewDelegate respondsToSelector:@selector(editorViewDidChangeSelection:)];
    _editorViewDelegateFlags.delegateMenuItems = [editorViewDelegate respondsToSelector:@selector(menuItems)];
    _editorViewDelegateFlags.delegateCanPerformActionsWithSender = [editorViewDelegate respondsToSelector:@selector(editorView:canPerformAction:withSender:)];
}

#pragma mark - Editing State

@synthesize editable = _editable;

- (void)setEditable:(BOOL)editable
{
    if (_editable == editable)
        return;
    
    _editable = editable;
    
    self.overrideEditorViewDelegate = YES;
    [self resignFirstResponder];
    self.overrideEditorViewDelegate = NO;
}

@synthesize editing = _editing;

- (void)setEditing:(BOOL)editing
{
    if (_editing == editing)
        return;
    
    _editing = editing;
    
    if (editing)
    {
        // set cursor at end of document if nothing selected
        if (!_selectedTextRange)
        {
            UITextPosition *end = [self endOfDocument];
            DTTextRange *textRange = (DTTextRange *)[self textRangeFromPosition:end toPosition:end];
            
            [self setSelectedTextRange:textRange animated:NO];
        }
        else
        {
            [self updateCursorAnimated:NO];
        }
        
        // Notify editor delegate that editing began
        if (_editorViewDelegateFlags.delegateDidBeginEditing)
        {
            [self.editorViewDelegate editorViewDidBeginEditing:self];
        }
        
        // Post the DTRichTextEditorTextDidBeginEditing notification
        [[NSNotificationCenter defaultCenter] postNotificationName:DTRichTextEditorTextDidBeginEditingNotification object:self];
    }
    else
    {
        // Cleanup cursor, selection view, and context menu
        [self updateCursorAnimated:NO];
        [self hideContextMenu];
        
        // Notify editor delegate that editing ended
        if (_editorViewDelegateFlags.delegateDidEndEditing)
        {
            [self.editorViewDelegate editorViewDidEndEditing:self];
        }
        
        // Post the DTRichTextEditorTextDidEndEditing notification
        [[NSNotificationCenter defaultCenter] postNotificationName:DTRichTextEditorTextDidEndEditingNotification object:self];
    }
}


#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    if (self.isEditable && _editorViewDelegateFlags.delegateShouldBeginEditing && !self.overrideEditorViewDelegate && !_isChangingInputView)
    {
        return [self.editorViewDelegate editorViewShouldBeginEditing:self];
    }
    
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    
    if (!self.isFirstResponder)
        return NO;
    
    // Initiate editing
    if (self.isEditable)
    {
        [self setEditing:YES];
    }
    
    // Add editor menu items and editor view delegate menu items
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithArray:self.editorMenuItems];
	
    if (_editorViewDelegateFlags.delegateMenuItems)
    {
        // Filter delegate's menu items to remove any that would interfere with our code
        for (UIMenuItem *menuItem in self.editorViewDelegate.menuItems)
        {
            if (![self respondsToSelector:menuItem.action])
            {
                [menuItems addObject:menuItem];
            }
        }
    }
    
    [[UIMenuController sharedMenuController] setMenuItems:menuItems];
    
    return YES;
}

- (BOOL)canResignFirstResponder
{
    if (self.isEditing && !self.overrideEditorViewDelegate && _editorViewDelegateFlags.delegateShouldEndEditing && !_isChangingInputView)
    {
        return [self.editorViewDelegate editorViewShouldEndEditing:self];
    }
	
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    
    if (!self.isFirstResponder && !_isChangingInputView)
    {
        if (self.isEditing)
        {
            [self setEditing:NO];
        }
        else
        {
            // Clear markings
            [self updateCursorAnimated:YES];
            [self hideContextMenu];
        }
        
        // Remove custom menu items
        [[UIMenuController sharedMenuController] setMenuItems:nil];
    }
	
    return !self.isFirstResponder;
}

- (UIResponder *)nextResponder
{
    if (_stopResponderChain)
    {
        _stopResponderChain = NO;
        return nil;
    }
    
    return [super nextResponder];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    // If the delegate provides custom menu items, check to see if this selector is one of the menu items
    if (_editorViewDelegateFlags.delegateMenuItems)
    {
        // Check delegate's custom menu items and return the delegate as the forwarding target if action matches
        for (UIMenuItem *menuItem in self.editorViewDelegate.menuItems)
        {
            if (menuItem.action == aSelector)
                return self.editorViewDelegate;
        }
    }
    
    return nil;
}

- (NSArray *)editorMenuItems
{
    if (_editorMenuItems == nil)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if ([UIReferenceLibraryViewController class])
        {
            UIMenuItem *defineItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Define", @"Menu item title for defining a selected term")
                                                                action:@selector(define:)];
            [items addObject:defineItem];
        }
        
        _editorMenuItems = items;
    }
    
    return _editorMenuItems;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    // Delegate gets the first say, can disable any action
    if (_editorViewDelegateFlags.delegateCanPerformActionsWithSender)
    {
        if (![self.editorViewDelegate editorView:self canPerformAction:action withSender:sender])
        {
            _stopResponderChain = YES;
            return NO;
        }
        
        if (_editorViewDelegateFlags.delegateMenuItems)
        {
            // Check delegate's custom menu items and return YES if action matches
            for (UIMenuItem *menuItem in self.editorViewDelegate.menuItems)
            {
                if (menuItem.action == action && ![self respondsToSelector:menuItem.action])
                    return YES;
            }
        }
    }
    
	if (action == @selector(selectAll:))
	{
		if (([[_selectedTextRange start] isEqual:(id)[self beginningOfDocument]] && [[_selectedTextRange end] isEqual:(id)[self endOfDocument]]) || ![_selectedTextRange isEmpty])
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	
	if (action == @selector(select:))
	{
		// selection only possibly from cursor, not when already selection in place
		if ([_selectedTextRange length])
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	
	// stuff below needs a selection
	if (!_selectedTextRange)
	{
		return NO;
	}
	
	if (!_canInteractWithPasteboard)
	{
		return NO;
	}
	
	if (action == @selector(paste:))
	{
        if (!self.isEditing)
        {
            return NO;
        }
		return [self pasteboardHasSuitableContentForPaste];
	}
	
	// stuff below needs a selection with multiple chars
	if ([_selectedTextRange isEmpty])
	{
		return NO;
	}
	
	if (action == @selector(cut:))
	{
        if (!self.isEditing)
        {
            return NO;
        }
		return YES;
	}
	
	if (action == @selector(copy:))
	{
		return YES;
	}
    
    if (action == @selector(define:))
    {
        if( ![UIReferenceLibraryViewController class] )
            return NO;
        
        NSString *selectedTerm = [self textInRange:self.selectedTextRange];
        return [UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:selectedTerm];
    }
	
	
	return NO;
}

- (void)delete:(id)sender
{
	if ([_selectedTextRange isEmpty])
	{
		return;
	}
	
    [self _inputDelegateTextWillChange];
	[self replaceRange:_selectedTextRange withText:@""];
    [self _inputDelegateTextDidChange];
    
	[self.undoManager setActionName:NSLocalizedString(@"Delete", @"Action that deletes text")];
}

- (void)cut:(id)sender
{
	if ([_selectedTextRange isEmpty])
	{
		return;
	}
    
    // Check with editor delegate to allow change
    if (_editorViewDelegateFlags.delegateShouldChangeTextInRangeReplacementText)
    {
        NSRange selectedTextRange = [(DTTextRange *)self.selectedTextRange NSRangeValue];
        NSAttributedString *replacementText = [[NSAttributedString alloc] init];
        
        if (![self.editorViewDelegate editorView:self shouldChangeTextInRange:selectedTextRange replacementText:replacementText])
            return;
    }
    
	// first step is identical with copy
	[self copy:sender];
	
	// second set is removing what was copied
	[self delete:sender];
	
	[self.undoManager setActionName:NSLocalizedString(@"Cut", @"Undo Action that cuts text")];
    
    // Notify editor delegate of change
    [self _editorViewDelegateDidChange];
}

- (void)copy:(id)sender
{
	if ([_selectedTextRange isEmpty])
	{
		return;
	}
	
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	
	NSRange selectedRange = [_selectedTextRange NSRangeValue];
	
	if ([_selectedTextRange.end isEqual:[self endOfDocument]])
	{
		// we also want the ending paragraph mark
		selectedRange.length ++;
	}
	
	NSAttributedString *attributedString = [self.attributedTextContentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:selectedRange];
	
	// plain text omits attachments and format
	NSString *plainText = [attributedString plainTextString];
	
	// all HTML generation goes via a writer
	DTHTMLWriter *writer = [[DTHTMLWriter alloc] initWithAttributedString:attributedString];
	
	// set text scale if set
	NSDictionary *defaults = [self textDefaults];
	NSNumber *scale = [defaults objectForKey:NSTextSizeMultiplierDocumentOption];
	if (scale)
	{
		writer.textScale = [scale floatValue];
	}
	
	// create a web archive
	DTWebArchive *webArchive = [writer webArchive];
	NSData *data = [webArchive data];
	
	// set multiple formats at the same time
	NSArray *items = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:data, WebArchivePboardType, plainText, @"public.utf8-plain-text", nil], nil];
	[pasteboard setItems:items];
}

- (void)paste:(id)sender
{
	if (!_selectedTextRange)
	{
		return;
	}
    
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	
	UIImage *image = [pasteboard image];
	
	if (image)
	{
        Class ImageAttachmentClass = [DTTextAttachment registeredClassForTagName:@"img"];
        NSAssert([ImageAttachmentClass isSubclassOfClass:[DTImageTextAttachment class]], @"DTRichTextEditor requires DTImageTextAttachment or a subclass of it be registered for 'img' tags.");
        
        DTImageTextAttachment *attachment = [[ImageAttachmentClass alloc] initWithElement:nil options:nil];
        attachment.contentURL = [pasteboard URL];
		attachment.image = image;
		attachment.originalSize = [image size];
		
		CGSize displaySize = image.size;
		if (!CGSizeEqualToSize(_maxImageDisplaySize, CGSizeZero))
		{
			if (_maxImageDisplaySize.width < image.size.width || _maxImageDisplaySize.height < image.size.height)
			{
				displaySize = sizeThatFitsKeepingAspectRatio(image.size,_maxImageDisplaySize);
			}
		}
        
        attachment.displaySize = displaySize;
        
        NSAttributedString *attachmentString = [self attributedStringForTextRange:_selectedTextRange wrappingAttachment:attachment inParagraph:NO];
        [self _pasteAttributedString:attachmentString inRange:_selectedTextRange];
		
		return;
	}
	
	NSURL *url = [pasteboard URL];
	
	if (url)
	{
		NSAttributedString *attributedText = [NSAttributedString attributedStringWithURL:url];
        [self _pasteAttributedString:attributedText inRange:_selectedTextRange];
		
		return;
	}
	
	DTWebArchive *webArchive = [pasteboard webArchive];
	
	if (webArchive)
	{
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithWebArchive:webArchive options:[self textDefaults] documentAttributes:NULL];
		
		if (attributedText)
		{
			
			[self _pasteAttributedString:attributedText inRange:_selectedTextRange];
			
			return;
		}
	}
	
	NSData *HTMLdata = [pasteboard dataForPasteboardType:@"public.html"];
    
    if (HTMLdata)
    {
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithHTMLData:HTMLdata options:[self textDefaults] documentAttributes:NULL];
        [self _pasteAttributedString:attributedText inRange:_selectedTextRange];
		
		return;
    }
    
	NSString *string = [pasteboard string];
	
	if (string)
	{
		// plain text string should always be treated as if is was typed, must have font attribute
		NSDictionary *typingAttributes = self.overrideInsertionAttributes;
		
		if (!typingAttributes)
		{
			typingAttributes = [self typingAttributesForRange:_selectedTextRange];
		}
		
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:typingAttributes];
		
		[self _pasteAttributedString:attributedText inRange:_selectedTextRange];
		
		return;
	}
}

- (void)_pasteAttributedString:(NSAttributedString *)attributedStringToPaste inRange:(DTTextRange *)textRange
{
    if (_editorViewDelegateFlags.delegateShouldChangeTextInRangeReplacementText)
        if (![self.editorViewDelegate editorView:self shouldChangeTextInRange:[textRange NSRangeValue] replacementText:attributedStringToPaste])
            return;
    
    if (_editorViewDelegateFlags.delegateWillPasteTextInRange)
    {
        attributedStringToPaste = [self.editorViewDelegate editorView:self
                                                        willPasteText:attributedStringToPaste
                                                              inRange:[textRange NSRangeValue]];
        if (attributedStringToPaste == nil)
            return;
    }
    
    DTUndoManager *undoManager = (DTUndoManager *)self.undoManager;
	[undoManager closeAllOpenGroups];
    
    [self _inputDelegateTextWillChange];
    [self replaceRange:textRange withText:attributedStringToPaste];
    [self.undoManager setActionName:NSLocalizedString(@"Paste", @"Undo Action that pastes text")];
    [self _inputDelegateTextDidChange];
    
    [self _editorViewDelegateDidChange];
}

- (void)select:(id)sender
{
	UITextPosition *currentPosition = (DTTextPosition *)[_selectedTextRange start];
	UITextRange *wordRange = [self textRangeOfWordAtPosition:currentPosition];
	
	if (wordRange)
	{
		_shouldReshowContextMenuAfterHide = YES;
		self.selectionView.dragHandlesVisible = YES;
		
		self.selectedTextRange = wordRange;
	}
}

- (void)selectAll:(id)sender
{
	_shouldReshowContextMenuAfterHide = YES;
    self.selectionView.dragHandlesVisible = YES;
	
	self.selectedTextRange = [DTTextRange textRangeFromStart:self.beginningOfDocument toEnd:self.endOfDocument];
}

- (void)define:(id)sender
{
    if (![UIReferenceLibraryViewController class])
        return;
    
    if (!self.selectedTextRange || [self.selectedTextRange isEmpty])
        return;
    
    NSString *selectedTerm = [self textInRange:self.selectedTextRange];
    
    if (![UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:selectedTerm])
        return;
    
    UIReferenceLibraryViewController *dictionaryViewController = [[UIReferenceLibraryViewController alloc] initWithTerm:selectedTerm];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *window = [application keyWindow];
        [window.rootViewController presentViewController:dictionaryViewController animated:YES completion:nil];
    }
    else // iPad
    {
        CGRect targetRect = [self visibleBoundsOfCurrentSelection];
        
        if (CGRectIsNull(targetRect))
            return;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:dictionaryViewController];
        popover.delegate = self;
        [popover presentPopoverFromRect:targetRect
                                 inView:self
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
        
        self.definePopoverController = popover;
    }
}

// creates an undo manager lazily in response to a shake gesture or first edit action
- (DTUndoManager *)undoManager
{
    if (_undoManager == nil)
    {
        _undoManager = [[DTUndoManager alloc] init];
    }
	
	return _undoManager;
}


#pragma mark - UIKeyInput Protocol

- (BOOL)hasText
{
	// there should always be a \n with the default format
	
	NSAttributedString *currentContent = self.attributedTextContentView.layoutFrame.attributedStringFragment;
	
	// has to have text
	if ([currentContent length]>1)
	{
		return YES;
	}
	
	// only a paragraph break = no text
	if ([[currentContent string] isEqualToString:@"\n"])
	{
		return NO;
	}
	
	// all other scenarios: no text
	return NO;
}

- (void)insertText:(NSString *)text
{
    
    // Check with editor delegate to allow change
    if (_editorViewDelegateFlags.delegateShouldChangeTextInRangeReplacementText)
    {
        NSRange range = [(DTTextRange *)self.selectedTextRange NSRangeValue];
        NSAttributedString *replacementText = [[NSAttributedString alloc] initWithString:text];
        
        if (![self.editorViewDelegate editorView:self shouldChangeTextInRange:range replacementText:replacementText])
            return;
    }
	
	DTUndoManager *undoManager = (DTUndoManager *)self.undoManager;
	if (!undoManager.numberOfOpenGroups)
	{
		[self.undoManager beginUndoGrouping];
	}
	
	if (_replaceParagraphsWithLineFeeds)
	{
		text = [text stringByReplacingOccurrencesOfString:@"\n" withString:UNICODE_LINE_FEED];
	}
	
	if (!text)
	{
		text = @"";
	}
	
	if (self.markedTextRange)
	{
        self.userIsTyping = YES;
		[self replaceRange:self.markedTextRange withText:text];
        self.userIsTyping = NO;
        
		[self unmarkText];
	}
	else
	{
        if ([text isEqualToString:@"\n"])
        {
            // NL entered, returns YES if it was inside a list
            if ([self handleNewLineInputInListInRange:self.selectedTextRange])
            {
                return;
            }
        }
        
        self.userIsTyping = YES;
		[self replaceRange:self.selectedTextRange withText:text];
        self.userIsTyping = NO;
        
		// leave marking intact
	}
	
	// hide context menu on inserting text
	[self hideContextMenu];
    
    // Notify editor delegate of change
    [self _editorViewDelegateDidChange];
}

- (void)deleteBackward
{
	DTTextRange *replacementTextRange = (id)[self selectedTextRange];
	UITextRange *entireDocument = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
	
	// extending the selection towards beginning is done for us on iOS 7
	if ([replacementTextRange isEmpty])
	{
		// nothing to delete past beginning of document
		if ([replacementTextRange.start isEqual:self.beginningOfDocument])
		{
			return;
		}
		
		// extend deletion range towards beginning of document
		UITextPosition *delStart = [self positionFromPosition:replacementTextRange.start offset:-1];
		replacementTextRange = [DTTextRange textRangeFromStart:delStart toEnd:[replacementTextRange start]];
	}

	// make sure that the beginning is before any fields
	UITextPosition *delStart = [self positionSkippingFieldsFromPosition:replacementTextRange.start withinRange:entireDocument inDirection:UITextStorageDirectionBackward];
	replacementTextRange = [DTTextRange textRangeFromStart:delStart toEnd:replacementTextRange.end];
	
	NSAttributedString *replacementText = [[NSAttributedString alloc] init];
	
    // Check with editor delegate to allow change
    if (_editorViewDelegateFlags.delegateShouldChangeTextInRangeReplacementText)
    {
        if (![self.editorViewDelegate editorView:self shouldChangeTextInRange:[replacementTextRange NSRangeValue] replacementText:replacementText])
		{
            return;
		}
    }
    
    // Prepare undo
	DTUndoManager *undoManager = (DTUndoManager *)self.undoManager;
	if (!undoManager.numberOfOpenGroups)
	{
		[self.undoManager beginUndoGrouping];
	}
	
	// Delete
    [self replaceRange:replacementTextRange withText:replacementText];
	
	// hide context menu on deleting text
	[self hideContextMenu];
    
    // Notify editor delegate of change
    [self _editorViewDelegateDidChange];
}

#pragma mark


#pragma mark UITextInput Protocol
#pragma mark -
#pragma mark Replacing and Returning Text

/* Methods for manipulating text. */
- (NSString *)textInRange:(UITextRange *)range
{
	DTTextPosition *startPosition = (DTTextPosition *)range.start;
	DTTextPosition *endPosition = (DTTextPosition *)range.end;
	
	// on iOS 5 the upper end of the range might be "unbounded" (NSIntegerMax)
	if ([endPosition compare:(DTTextPosition *)self.endOfDocument]==NSOrderedDescending)
	{
		endPosition = (DTTextPosition *)self.endOfDocument;
	}
	
	range = [self textRangeFromPosition:startPosition toPosition:endPosition];
	NSAttributedString *fragment = [self attributedSubstringForRange:range];
	
	return [fragment string];
}

- (void)replaceRange:(DTTextRange *)range withText:(id)text
{
	NSParameterAssert(range);
    
    NSAttributedString *attributedStringBeingReplaced = nil;
    
    if (_waitingForDictationResult)
    {
        // get selection range of placeholder
        range = (DTTextRange *)[self textRangeOfDictationPlaceholder];
        
        // we don't want extra whitespace
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // get placeholder
        DTDictationPlaceholderTextAttachment *attachment = [self dictationPlaceholderAtPosition:[range start]];
        attributedStringBeingReplaced = attachment.replacedAttributedString;
    }
    
	NSAttributedString *attributedText = self.attributedText;
	NSString *string = [attributedText string];
	
	// remember selection/cursor before input
	UITextRange *textRangeBeforeChange = self.selectedTextRange;
	
	NSRange myRange = [range NSRangeValue];
	
	// extend range to include part of composed character sequences as well
	NSRange composedRange = [string rangeOfComposedCharacterSequenceAtIndex:myRange.location];
	
	if (composedRange.location<myRange.location)
	{
		myRange = NSUnionRange(myRange, composedRange);
	}
	
	NSRange rangeToSelectAfterReplace = NSMakeRange(myRange.location + [text length], 0);
	
	if (!text)
	{
		// text could be nil, but that's not valid for replaceCharactersInRange
		text = @"";
	}
	
	NSDictionary *typingAttributes = self.overrideInsertionAttributes;
	
	if (!typingAttributes)
	{
		typingAttributes = [self typingAttributesForRange:range];
	}
	
	BOOL newlineEntered = NO;
	
	if ([text isKindOfClass:[NSString class]])
	{
		// if we are inside a list and the text ends with NL we need list prefix
		if ([text hasSuffix:@"\n"])
		{
			newlineEntered = YES;
		}
		
		// need to replace attributes with typing attributes
		text = [[NSAttributedString alloc] initWithString:text attributes:typingAttributes];
	}
	
	// ---
	
	NSUndoManager *undoManager = self.undoManager;
	[undoManager beginUndoGrouping];
	
	// restore selection/cursor together with the previous text
	// the replaceRange:withText: also modifies the selection so we need to restore this first
	[[undoManager prepareWithInvocationTarget:self] setSelectedTextRange:textRangeBeforeChange];
	
	// this is the string to restore if we undo
    if (!attributedStringBeingReplaced)
    {
        attributedStringBeingReplaced = [attributedText attributedSubstringFromRange:myRange];
    }
	
	// the range that the replacement will have afterwards
	NSRange replacedRange = NSMakeRange(myRange.location, [text length]);
	DTTextRange *replacedTextRange = [DTTextRange rangeWithNSRange:replacedRange];
	
	[[undoManager prepareWithInvocationTarget:self] replaceRange:replacedTextRange withText:(id)attributedStringBeingReplaced];
	
	// do the actual replacement
	[(DTRichTextEditorContentView *)self.attributedTextContentView replaceTextInRange:myRange withText:text];
	
	if (![undoManager isUndoing] && ![undoManager isRedoing])
	{
        if (_waitingForDictationResult)
        {
            [self.undoManager setActionName:NSLocalizedString(@"Dictation", @"Undo Action when text is entered via dictation")];
        }
        else
        {
            [self.undoManager setActionName:NSLocalizedString(@"Typing", @"Undo Action when text is entered")];
        }
	}
	
	[undoManager endUndoGrouping];
	
	// ----
	
	self.contentSize = self.attributedTextContentView.frame.size;
	
    // if it's just one character remaining then set text defaults on this
    if ([[self.attributedTextContentView.layoutFrame.attributedStringFragment string] isEqualToString:@"\n"])
    {
        NSDictionary *typingDefaults = [self attributedStringAttributesForTextDefaults];
        
        [(NSMutableAttributedString *)self.attributedTextContentView.layoutFrame.attributedStringFragment setAttributes:typingDefaults range:NSMakeRange(0, 1)];
    }
	
    // need to call extra because we control layouting
    [self setNeedsLayout];
	
	if (self.isEditing)
	{
		self.selectedTextRange = [DTTextRange rangeWithNSRange:rangeToSelectAfterReplace];
        
        // changing the selected text range resets the override attributes, so we need to these if the user hit enter
        if (newlineEntered && [_selectedTextRange isEmpty])
        {
            // without this it takes the typing attributes of the following line, losing e.g. boldness
            self.overrideInsertionAttributes = typingAttributes;
        }
	}
	else
	{
		self.selectedTextRange = nil;
	}
	
	[self updateCursorAnimated:NO];
	[self scrollCursorVisibleAnimated:YES];
    
    self.waitingForDictionationResult = NO;
	
	
	// if the number of paragraphs change we might have to renumber something
	NSUInteger paragraphsBeforeReplacement = [[attributedStringBeingReplaced string] numberOfParagraphs];
	NSUInteger paragraphsAfterReplacement = [[text string] numberOfParagraphs];
	
	if (paragraphsAfterReplacement != paragraphsBeforeReplacement)
	{
		[self updateListsInRange:_selectedTextRange removeNonPrefixedLinesFromLists:YES];
	}
}

#pragma mark Working with Marked and Selected Text
- (DTTextRange *)selectedTextRange
{
	return (id)_selectedTextRange;
}

- (void)setSelectedTextRange:(DTTextRange *)selectedTextRange animated:(BOOL)animated
{
	UITextRange *newTextRange = selectedTextRange;
	
	if (selectedTextRange != nil)
	{
		// check if the selected range fits with the attributed text
		DTTextPosition *start = (DTTextPosition *)newTextRange.start;
		DTTextPosition *end = (DTTextPosition *)newTextRange.end;
		
		if ([end compare:(DTTextPosition *)[self endOfDocument]] == NSOrderedDescending)
		{
			end = (DTTextPosition *)[self endOfDocument];
		}
		
		if ([start compare:end] == NSOrderedDescending)
		{
			start = end;
		}
		
		newTextRange = [DTTextRange textRangeFromStart:start toEnd:end];
	}
	
	if (_selectedTextRange && [_selectedTextRange isEqual:selectedTextRange])
	{
		// no change
		return;
	}
	
	[self willChangeValueForKey:@"selectedTextRange"];
	
	_selectedTextRange = [newTextRange copy];
	
	[self didChangeValueForKey:@"selectedTextRange"];
	
    // Notify the editor delegate if not dragging
	if (_dragMode != DTDragModeCursor && _dragMode != DTDragModeCursorInsideMarking)
	{
		[self _editorViewDelegateDidChangeSelection];
	}
	
	[self updateCursorAnimated:animated];
	[self hideContextMenu];
	
	self.overrideInsertionAttributes = nil;
}

- (void)setSelectedTextRange:(DTTextRange *)newTextRange
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, newTextRange);
	
	[self setSelectedTextRange:newTextRange animated:NO];
}

- (UITextRange *)markedTextRange
{
	// must return nil, otherwise backspacing acts weird
	if ([_markedTextRange isEmpty])
	{
		return nil;
	}
	
	return (id)_markedTextRange;
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    // Calculate ranges
    DTTextRange *selectedTextRange = (DTTextRange *)self.selectedTextRange;
    DTTextRange *markedTextRange = (DTTextRange *)self.markedTextRange;
    DTTextRange *replaceRange = (markedTextRange) ? markedTextRange : selectedTextRange;
    
    DTTextPosition *markedTextRangeStart = (DTTextPosition *)replaceRange.start;
    DTTextRange *newMarkedTextRange = [DTTextRange rangeWithNSRange:NSMakeRange(markedTextRangeStart.location, [markedText length])];
    
    NSRange newSelectedRange = NSMakeRange(markedTextRangeStart.location + selectedRange.location, selectedRange.length);
    DTTextRange *newSelectedTextRange = [DTTextRange rangeWithNSRange:newSelectedRange];
    
    
    // Update the text storage (We capture undo for the replacement and selectedTextRange, but calling undo will cancel multi-stage input and remove markings)
    NSUndoManager *undoManager = self.undoManager;
    
    if (markedTextRange == nil)
        [undoManager beginUndoGrouping]; // Overall marked session group began
    
    [undoManager beginUndoGrouping];
	
    [[undoManager prepareWithInvocationTarget:self.inputDelegate] textDidChange:self];
    [[undoManager prepareWithInvocationTarget:self] setSelectedTextRange:selectedTextRange];
	
    self.markedTextRange = newMarkedTextRange;
    [self replaceRange:replaceRange withText:markedText]; // Registers undo for the text replacement
    self.selectedTextRange = newSelectedTextRange;
    
    [[undoManager prepareWithInvocationTarget:self] setMarkedTextRange:nil];
    [[undoManager prepareWithInvocationTarget:self.inputDelegate] textWillChange:self];
	
    [undoManager endUndoGrouping];
    
    if (markedText.length == 0)
        [undoManager endUndoGrouping]; // Overall marked session group ended
    
    // Notify delegate
    [self _editorViewDelegateDidChange];
}

- (void)unmarkText
{
	if (!_markedTextRange)
	{
		return;
	}
	
	self.markedTextRange = nil;
	
	[self updateCursorAnimated:NO];
}

#pragma mark Computing Text Ranges and Text Positions
- (UITextRange *)textRangeFromPosition:(DTTextPosition *)fromPosition toPosition:(DTTextPosition *)toPosition
{
	return [DTTextRange textRangeFromStart:fromPosition toEnd:toPosition];
}

- (UITextPosition *)positionFromPosition:(DTTextPosition *)position offset:(NSInteger)offset
{
	DTTextPosition *begin = (id)[self beginningOfDocument];
	DTTextPosition *end = (id)[self endOfDocument];
    
	if (offset<0)
	{
		if (([begin compare:position] == NSOrderedAscending))
		{
			NSInteger newLocation = position.location+offset;
			
			// position.location is unsigned, so we need to be careful to not underflow
			if (newLocation>(NSInteger)begin.location)
			{
				return [DTTextPosition textPositionWithLocation:newLocation];
			}
			else
			{
				return begin;
			}
		}
		else
		{
			return begin;
		}
	}
	
	if (offset>0)
	{
        DTTextPosition *newPosition = [DTTextPosition textPositionWithLocation:position.location+offset];
        
        // return new position if it is before the document end, otherwise return end
		if (([newPosition compare:end] == NSOrderedAscending))
		{
			return newPosition;
		}
		else
		{
			return end;
		}
	}
	
	return position;
}


// limits position to be inside the range
- (UITextPosition *)positionFromPosition:(UITextPosition *)position withinRange:(UITextRange *)range
{
    UITextPosition *beginningOfDocument = [self beginningOfDocument];
    UITextPosition *endOfDocument = [self endOfDocument];
    
    if ([self comparePosition:position toPosition:beginningOfDocument] == NSOrderedAscending)
    {
        // position is before begin
        return beginningOfDocument;
    }
	
    if ([self comparePosition:position toPosition:endOfDocument] == NSOrderedDescending)
    {
        // position is after end
        return endOfDocument;
    }
    
    // position is inside range
    return position;
}

// limits position to be in range and optionally skips list prefixes in the direction
- (UITextPosition *)positionSkippingFieldsFromPosition:(UITextPosition *)position withinRange:(UITextRange *)range inDirection:(UITextStorageDirection)direction
{
    NSInteger index = [(DTTextPosition *)position location];
    
    // skip over list prefix
    NSAttributedString *attributedString = self.attributedText;
    NSRange listPrefixRange = [attributedString rangeOfFieldAtIndex:index];
    
    UITextPosition *newPosition = position;
    
    if (listPrefixRange.location != NSNotFound)
    {
        // there is a prefix, skip it according to direction
        switch (direction)
        {
            case UITextStorageDirectionForward:
            {
                // position after prefix
                newPosition = [DTTextPosition textPositionWithLocation:NSMaxRange(listPrefixRange)];
                break;
            }
                
            case UITextStorageDirectionBackward:
            {
                // position before prefix
                UITextPosition *positionOfPrefix = [DTTextPosition textPositionWithLocation:listPrefixRange.location];
                newPosition = [self positionFromPosition:positionOfPrefix offset:-1];
                break;
            }
        }
    }
    
    // limit the position to be within the range
    return [self positionFromPosition:newPosition withinRange:range];
}


- (UITextPosition *)positionFromPosition:(DTTextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
	UITextPosition *beginningOfDocument = (id)[self beginningOfDocument];
	UITextPosition *endOfDocument = (id)[self endOfDocument];
	UITextRange *entireDocument = [self textRangeFromPosition:beginningOfDocument toPosition:endOfDocument];
	
	// shift beginning over a list prefix
	endOfDocument = [self positionSkippingFieldsFromPosition:endOfDocument withinRange:entireDocument inDirection:UITextStorageDirectionBackward];
	
	// shift end over a list prefix
	beginningOfDocument = [self positionSkippingFieldsFromPosition:beginningOfDocument withinRange:entireDocument inDirection:UITextStorageDirectionForward];
	
	// update legal range
	UITextRange *maxRange = [self textRangeFromPosition:beginningOfDocument toPosition:endOfDocument];
	
	UITextPosition *maxPosition = [self positionWithinRange:maxRange farthestInDirection:direction];
	
	if ([self comparePosition:position toPosition:maxPosition] == NSOrderedSame)
	{
		// already at limit
		return nil;
	}
	
	UITextPosition *retPosition = nil;
	
	switch (direction)
	{
		case UITextLayoutDirectionRight:
		{
			UITextPosition *newPosition = [self positionFromPosition:position offset:1];
			
			// TODO: make the skipping direction dependend on the text direction in this paragraph
			retPosition = [self positionSkippingFieldsFromPosition:newPosition withinRange:entireDocument inDirection:UITextStorageDirectionForward];
			break;
		}
			
		case UITextLayoutDirectionLeft:
		{
			UITextPosition *newPosition = [self positionFromPosition:position offset:-1];
			
			// TODO: make the skipping direction dependend on the text direction in this paragraph
			retPosition = [self positionSkippingFieldsFromPosition:newPosition withinRange:entireDocument inDirection:UITextStorageDirectionBackward];
			break;
		}
			
		case UITextLayoutDirectionDown:
		{
			NSInteger index = [self.attributedTextContentView.layoutFrame indexForPositionDownwardsFromIndex:position.location offset:offset];
			
			// document ends
			if (index == NSNotFound)
			{
				return maxPosition;
			}
			
			UITextPosition *newPosition = [DTTextPosition textPositionWithLocation:index];
			
			// limit the position to be within the range and skip list prefixes
			retPosition = [self positionSkippingFieldsFromPosition:newPosition withinRange:entireDocument inDirection:UITextStorageDirectionForward];
			break;
		}
			
		case UITextLayoutDirectionUp:
		{
			NSInteger index = [self.attributedTextContentView.layoutFrame indexForPositionUpwardsFromIndex:position.location offset:offset];
			
			// nothing up there
			if (index == NSNotFound)
			{
				return maxPosition;
			}
			
			UITextPosition *newPosition = [DTTextPosition textPositionWithLocation:index];
			
			// limit the position to be within the range and skip list prefixes
			retPosition = [self positionSkippingFieldsFromPosition:newPosition withinRange:entireDocument inDirection:UITextStorageDirectionForward];
			break;
		}
	}
	
	return retPosition;
}

- (UITextPosition *)beginningOfDocument
{
	return [DTTextPosition textPositionWithLocation:0];
}

- (UITextPosition *)endOfDocument
{
	if ([self hasText])
	{
		return [DTTextPosition textPositionWithLocation:[self.attributedTextContentView.layoutFrame.attributedStringFragment length]-1];
	}
	
	return [self beginningOfDocument];
}

#pragma mark Evaluating Text Positions
- (NSComparisonResult)comparePosition:(DTTextPosition *)position toPosition:(DTTextPosition *)other
{
	return [position compare:other];
}

- (NSInteger)offsetFromPosition:(DTTextPosition *)fromPosition toPosition:(DTTextPosition *)toPosition
{
	return toPosition.location - fromPosition.location;
}

#pragma mark Determining Layout and Writing Direction
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    switch (direction)
    {
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            return [range end];
			
        case UITextLayoutDirectionLeft:
        case UITextLayoutDirectionUp:
            return [range start];
    }
}

- (UITextRange *)characterRangeByExtendingPosition:(DTTextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    [[NSException exceptionWithName:@"Not Implemented" reason:@"When is this method being used?" userInfo:nil] raise];
    
	DTTextPosition *end = (id)[self endOfDocument];
	
	return [DTTextRange textRangeFromStart:position toEnd:end];
}

// TODO: How is this implemented correctly?
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
	return UITextWritingDirectionLeftToRight;
}

// TODO: How is this implemented correctly?
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
	
}

#pragma mark Geometry and Hit-Testing Methods
- (CGRect)firstRectForRange:(DTTextRange *)range
{
	return [self.attributedTextContentView.layoutFrame firstRectForRange:[range NSRangeValue]];
}

- (CGRect)caretRectForPosition:(DTTextPosition *)position
{
	NSInteger index = position.location;
	
	DTCoreTextLayoutLine *layoutLine = [self.attributedTextContentView.layoutFrame lineContainingIndex:index];
	
	CGRect caretRect = [self.attributedTextContentView.layoutFrame cursorRectAtIndex:index];
	
	caretRect.size.height = roundf(layoutLine.frame.size.height);
	caretRect.origin.x = roundf(caretRect.origin.x);
	caretRect.origin.y = roundf(layoutLine.frame.origin.y);
	
	return caretRect;
}

- (NSArray *)selectionRectsForRange:(UITextRange *)range
{
    return [self.attributedTextContentView.layoutFrame  selectionRectsForRange:[(DTTextRange *)range NSRangeValue]];
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
	NSInteger newIndex = [self.attributedTextContentView.layoutFrame closestCursorIndexToPoint:point];
    
    // move cursor out of a list prefix, we don't want those
    NSAttributedString *attributedString = self.attributedText;
    
    NSRange listPrefixRange = [attributedString rangeOfFieldAtIndex:newIndex];
    
    if (listPrefixRange.location != NSNotFound)
    {
        newIndex = NSMaxRange(listPrefixRange);
    }
	
	return [DTTextPosition textPositionWithLocation:newIndex];
}

// called when marked text is showing
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(DTTextRange *)range
{
	DTTextPosition *position = (id)[self closestPositionToPoint:point];
	
	if (range)
	{
		if ([position compare:[range start]] == NSOrderedAscending)
		{
			return [range start];
		}
		
		if ([position compare:[range end]] == NSOrderedDescending)
		{
			return [range end];
		}
	}
	
	return position;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
	NSInteger index = [self.attributedTextContentView.layoutFrame closestCursorIndexToPoint:point];
	
	DTTextPosition *position = [DTTextPosition textPositionWithLocation:index];
	DTTextRange *range = [DTTextRange textRangeFromStart:position toEnd:position];
	
	return range;
}

#pragma mark Text Input Delegate and Text Input Tokenizer
@synthesize inputDelegate;

- (id<UITextInputTokenizer>) tokenizer
{
	if (!tokenizer)
	{
		tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
	}
	
	return tokenizer;
}

#pragma mark Returning Text Styling Information
- (NSDictionary *)textStylingAtPosition:(DTTextPosition *)position inDirection:(UITextStorageDirection)direction
{
	if (!position)
	{
		return nil;
	}
	
	if ([position isEqual:(id)[self endOfDocument]])
	{
		direction = UITextStorageDirectionBackward;
	}
	
	NSDictionary *ctStyles;
	if (direction == UITextStorageDirectionBackward && position.location > 0)
	{
		ctStyles = [self.attributedTextContentView.layoutFrame.attributedStringFragment attributesAtIndex:position.location-1 effectiveRange:NULL];
	}
	else
	{
		if (position.location>=[self.attributedTextContentView.layoutFrame.attributedStringFragment length])
		{
			return nil;
		}
		
		ctStyles = [self.attributedTextContentView.layoutFrame.attributedStringFragment attributesAtIndex:position.location effectiveRange:NULL];
	}
	
	/* TODO: Return typingAttributes, if position is the same as the insertion point? */
	
	NSMutableDictionary *uiStyles = [ctStyles mutableCopy];
	
	CTFontRef ctFont = (__bridge CTFontRef)[ctStyles objectForKey:(id)kCTFontAttributeName];
	if (ctFont)
	{
		/* As far as I can tell, the name that UIFont wants is the PostScript name of the font. (It's undocumented, of course. RADAR 7881781 / 7241008) */
		CFStringRef fontName = CTFontCopyPostScriptName(ctFont);
		UIFont *uif = [UIFont fontWithName:(__bridge id)fontName size:CTFontGetSize(ctFont)];
		CFRelease(fontName);
		[uiStyles setObject:uif forKey:UITextInputTextFontKey];
	}
	
	CGColorRef cgColor = (__bridge CGColorRef)[ctStyles objectForKey:(id)kCTForegroundColorAttributeName];
	if (cgColor)
	{
		[uiStyles setObject:[UIColor colorWithCGColor:cgColor] forKey:UITextInputTextColorKey];
	}
	
	if (self.backgroundColor)
	{
		[uiStyles setObject:self.backgroundColor forKey:UITextInputTextBackgroundColorKey];
	}
	
	return uiStyles;
}

#pragma mark Returning the Text Input View
- (UIView *)textInputView
{
	return (id)self;
}

#pragma mark - Utilities

- (CGRect)visibleContentRect
{
	CGRect rect = self.bounds;
    
    rect.size.height -= _heightCoveredByKeyboard;
	
	return rect;
}

- (BOOL)selectionIsVisible
{
	CGRect visibleContentRect = [self visibleContentRect];
	CGRect selectionRect = [self boundsOfCurrentSelection];
	
	// selection is visible if the selection rect is in the visible rect
	if (!CGRectIntersectsRect(visibleContentRect, selectionRect))
	{
		return NO;
	}
	
	return YES;
}

- (void)relayoutText
{
	[self.attributedTextContentView relayoutText];
}

// pack the properties into a dictionary
- (NSDictionary *)textDefaults
{
	NSMutableDictionary *tmpDict = [_textDefaults mutableCopy];
	
	if (!tmpDict)
	{
		tmpDict = [NSMutableDictionary dictionary];
	}
	
	// modify the settings with the overrides
	if (!CGSizeEqualToSize(_maxImageDisplaySize, CGSizeZero))
	{
		[tmpDict setObject:[NSValue valueWithCGSize:_maxImageDisplaySize] forKey:DTMaxImageSize];
	}
	
	if (_baseURL)
	{
		[tmpDict setObject:_baseURL forKey:NSBaseURLDocumentOption];
	}
	
	if (_textSizeMultiplier>0)
	{
		[tmpDict setObject:[NSNumber numberWithFloat:_textSizeMultiplier] forKey:NSTextSizeMultiplierDocumentOption];
	}
    else
    {
		[tmpDict setObject:[NSNumber numberWithFloat:1.0f] forKey:NSTextSizeMultiplierDocumentOption];
    }
	
	if (_defaultFontFamily)
	{
		[tmpDict setObject:_defaultFontFamily forKey:DTDefaultFontFamily];
	}
    
    if (_defaultFontSize>0)
    {
        [tmpDict setObject:[NSNumber numberWithFloat:_defaultFontSize] forKey:DTDefaultFontSize];
    }
	
	// otherwise use set defaults
	return tmpDict;
}

- (void)setTextDefaults:(NSDictionary *)textDefaults
{
	if (_textDefaults != textDefaults)
	{
		_textDefaults = textDefaults;
        
        // extract values
        
        NSValue *maxImageSizeValue = [_textDefaults objectForKey:DTMaxImageSize];
        
        if (maxImageSizeValue)
        {
            _maxImageDisplaySize = [maxImageSizeValue CGSizeValue];
        }
        
        NSURL *baseURL = [_textDefaults objectForKey:NSBaseURLDocumentOption];
        
        if (baseURL)
        {
            _baseURL = baseURL;
        }
        
        NSNumber *textSizeNum = [_textDefaults objectForKey:NSTextSizeMultiplierDocumentOption];
        
        if (textSizeNum)
        {
            _textSizeMultiplier = [textSizeNum floatValue];
        }
        
        NSString *fontFamily = [_textDefaults objectForKey:DTDefaultFontFamily];
        
        if (fontFamily)
        {
            _defaultFontFamily = fontFamily;
        }
        
        NSNumber *fontSizeNum = [_textDefaults objectForKey:DTDefaultFontSize];
        
        if (fontSizeNum)
        {
            _defaultFontSize = [fontSizeNum floatValue];
        }
	}
}

// helper method for wrapping a text attachment, optionally in its own paragraph
- (NSAttributedString *)attributedStringForTextRange:(DTTextRange *)textRange wrappingAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
    NSRange range = [textRange NSRangeValue];
	NSMutableDictionary *attributes = [[self typingAttributesForRange:textRange] mutableCopy];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
	NSString *plainText = [self.attributedTextContentView.layoutFrame.attributedStringFragment string];
	
	if (inParagraph)
	{
		// determine if we need a paragraph break before or after the item
		if (range.location>0)
		{
			NSInteger index = range.location-1;
			
			unichar character = [plainText characterAtIndex:index];
			
			if (character != '\n')
			{
				needsParagraphBefore = YES;
			}
		}
		
		NSUInteger indexAfterRange = NSMaxRange(range);
		if (indexAfterRange<[plainText length])
		{
			unichar character = [plainText characterAtIndex:indexAfterRange];
			
			if (character != '\n')
			{
				needsParagraphAfter = YES;
			}
		}
	}
    
    // Build the wrapper string
	NSMutableAttributedString *wrapperString = [[NSMutableAttributedString alloc] initWithString:@""];
	
	if (needsParagraphBefore)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[wrapperString appendAttributedString:formattedNL];
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
	[wrapperString appendAttributedString:tmpStr];
	
	if (needsParagraphAfter)
	{
		NSAttributedString *formattedNL = [[NSAttributedString alloc] initWithString:@"\n" attributes:attributes];
		[wrapperString appendAttributedString:formattedNL];
	}
    
    return wrapperString;
}

#pragma mark - Delegate Communication

- (void)_inputDelegateSelectionWillChange
{
    // do not send this if we're entering text, this prevents the autocorrection prompt from appearing
    if (_userIsTyping)
    {
        return;
    }
    
    [self.inputDelegate selectionWillChange:self];
}

- (void)_inputDelegateSelectionDidChange
{
    // do not send this if we're entering text, this prevents the autocorrection prompt from appearing
    if (_userIsTyping)
    {
        return;
    }
	
    [self.inputDelegate selectionWillChange:self];
}

- (void)_inputDelegateTextWillChange
{
    [self.inputDelegate textWillChange:self];
}

- (void)_inputDelegateTextDidChange
{
    [self.inputDelegate textWillChange:self];
}

- (void)_editorViewDelegateDidChangeSelection
{
    // only notify on user input while editing
    if (self.isEditing && _editorViewDelegateFlags.delegateDidChangeSelection)
    {
        [self.editorViewDelegate editorViewDidChangeSelection:self];
    }
}

- (void)_editorViewDelegateDidChange
{
    // Notify delegate
    if (self.isEditing && _editorViewDelegateFlags.delegateDidChange)
    {
        [self.editorViewDelegate editorViewDidChange:self];
    }
    
    // Post DTRichTextEditorTextDidChangeNotification
    [[NSNotificationCenter defaultCenter] postNotificationName:DTRichTextEditorTextDidChangeNotification object:self];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.definePopoverController)
    {
        self.definePopoverController = nil;
    }
}

#pragma mark - Properties

- (void)setAttributedText:(NSAttributedString *)newAttributedText
{
	if (newAttributedText && newAttributedText.length > 0)
	{
		NSMutableAttributedString *tmpString = [newAttributedText mutableCopy];
		
		if (![[tmpString string] hasSuffix:@"\n"])
		{
			[tmpString appendString:@"\n"];
		}
		
		[self _setAttributedText:tmpString];
	}
	else
	{
        // setDefaultText -> setHTMLString: -> setAttributedText:
		[self setDefaultText];
	}
}

- (void)_setAttributedText:(NSAttributedString *)newAttributedText
{
    // setting new text should remove all selections
	[self unmarkText];
    
    [self _inputDelegateTextWillChange];
    [super setAttributedString:newAttributedText];
    [self _inputDelegateTextDidChange];
    
    [self setNeedsLayout];
    
	// always position cursor at the end of the text
    if (self.isEditing)
    {
        self.selectedTextRange = [self textRangeFromPosition:self.endOfDocument toPosition:self.endOfDocument];
    }
    
	[self.undoManager removeAllActions];
}

- (NSAttributedString *)attributedText
{
	return self.attributedTextContentView.layoutFrame.attributedStringFragment;
}

- (NSAttributedString *)attributedString
{
    return [super attributedString];
}

- (void)setMarkedTextRange:(UITextRange *)markedTextRange
{
	if (markedTextRange != _markedTextRange)
	{
		[self willChangeValueForKey:@"markedTextRange"];
		
		_markedTextRange = [markedTextRange copy];
		
		[self hideContextMenu];
		
		[self didChangeValueForKey:@"markedTextRange"];
	}
}

- (void)setContentSize:(CGSize)newContentSize
{
	[super setContentSize:newContentSize];
	
	self.selectionView.frame = self.attributedTextContentView.frame;
	[self updateCursorAnimated:NO];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    
    if (!_shouldNotRecordChangedContentInsets)
    {
        _userSetContentInsets = contentInset;
    }
}

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    [super setScrollIndicatorInsets:scrollIndicatorInsets];
    
    if (!_shouldNotRecordChangedContentInsets)
    {
        _userSetScrollIndicatorInsets = scrollIndicatorInsets;
    }
}

- (DTCursorView *)cursor
{
	if (!_cursor)
	{
		_cursor = [[DTCursorView alloc] initWithFrame:CGRectZero];
		[self addSubview:_cursor];
	}
	
	return _cursor;
}

- (DTTextSelectionView *)selectionView
{
	if (!_selectionView)
	{
		_selectionView = [[DTTextSelectionView alloc] initWithTextView:self.attributedTextContentView];
		[self addSubview:_selectionView];
	}
	
	return _selectionView;
}

// make sure that the selection rectangles are always in front of content view
- (void)addSubview:(UIView *)view
{
	if ([NSStringFromClass([view class]) rangeOfString:@"InlinePrompt"].length)
	{
		_autocorrectionPromptView = view;
		
		[self _updateContentInsetForKeyboardAnimated:NO];
	}
	
	[super addSubview:view];
	
	// content view should always be at back
	if (_attributedTextContentView)
	{
		[self sendSubviewToBack:_attributedTextContentView];
	}
	
	// selection view should be in front of everything
	if (_selectionView)
	{
		[self bringSubviewToFront:_selectionView];
	}
}

- (void)willRemoveSubview:(UIView *)subview
{
	[super willRemoveSubview:subview];
	
	if (subview == _autocorrectionPromptView)
	{
		_autocorrectionPromptView = nil;

		// wait a bit longer with removing the inset because the autocorrect prompt might come back right
		SEL selector = @selector(_updateContentInsetForKeyboardNonAnimated);
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
		[self performSelector:selector withObject:nil afterDelay:0.5];
	}
}

- (UIView *)inputView
{
    if (self.isEditable)
	{
		return _inputView;
	}
	
	return nil;
}

- (void)setInputView:(UIView *)inputView animated:(BOOL)animated
{
	if (_inputView == inputView)
	{
		return;
	}
	
	BOOL wasFirstResponder = self.isFirstResponder;
    
    [self willChangeValueForKey:@"inputView"];
	_inputView = inputView;
    [self didChangeValueForKey:@"inputView"];
	
	// only animate if we are first responder
	if (!wasFirstResponder)
	{
		return;
	}
    
	_isChangingInputView = YES;
	
	[self resignFirstResponder];
	
	// give the previous inputView time to animate out if we are animating
	double delayInSeconds = (animated && wasFirstResponder)?0.35:0;
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self becomeFirstResponder]; // this activates new input view
		
		_isChangingInputView = NO;
	});
}

- (void)setInputView:(UIView *)inputView
{
	[self setInputView:inputView animated:NO];
}

- (UIView *)inputAccessoryView
{
    if (self.isEditable)
	{
		return _inputAccessoryView;
	}
	
	return nil;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView
{
	if (_inputAccessoryView != inputAccessoryView)
	{
		_inputAccessoryView = inputAccessoryView;
	}
}

- (void)setFrame:(CGRect)frame
{
	if ([[UIMenuController sharedMenuController] isMenuVisible])
	{
		_shouldShowContextMenuAfterMovementEnded = YES;
	}
	
	[super setFrame:frame];
}

- (void)setWaitingForDictionationResult:(BOOL)waitingForDictionationResult
{
    if (_waitingForDictationResult != waitingForDictionationResult)
    {
        _waitingForDictationResult = waitingForDictionationResult;
        
        if (_waitingForDictationResult)
        {
            _cursor.state = DTCursorStateStatic;
        }
        else
        {
            _cursor.state = DTCursorStateBlinking;
        }
    }
}

// overrides
@synthesize maxImageDisplaySize = _maxImageDisplaySize;
@synthesize defaultFontFamily = _defaultFontFamily;
@synthesize defaultFontSize = _defaultFontSize;
@synthesize baseURL = _baseURL;
@synthesize textSizeMultiplier = _textSizeMultiplier;

// UITextInput
@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardAppearance;
@synthesize keyboardType;
@synthesize returnKeyType;
@synthesize secureTextEntry;
@synthesize selectionAffinity;
@synthesize spellCheckingType;

// other properties
@synthesize canInteractWithPasteboard = _canInteractWithPasteboard;
@synthesize cursor = _cursor;
@synthesize markedTextRange = _markedTextRange;
@synthesize markedTextStyle = _markedTextStyle;
@synthesize mutableLayoutFrame = _mutableLayoutFrame;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize inputView = _inputView;
@synthesize overrideInsertionAttributes = _overrideInsertionAttributes;
@synthesize replaceParagraphsWithLineFeeds = _replaceParagraphsWithLineFeeds;
@synthesize selectionView = _selectionView;
@synthesize waitingForDictionationResult = _waitingForDictionationResult;
@synthesize dictationPlaceholderView = _dictationPlaceholderView;
@synthesize editorMenuItems = _editorMenuItems;

@synthesize userIsTyping = _userIsTyping;
@synthesize keepCurrentUndoGroup = _keepCurrentUndoGroup;

@end

