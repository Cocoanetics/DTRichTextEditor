//
//  DTRichTextEditorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DTLoupeView.h"

#import "DTAttributedTextContentView.h"
#import "NSString+HTML.h"
#import "NSString+Paragraphs.h"
#import "DTHTMLElement.h"
#import "DTCoreTextLayoutFrame.h"
#import "DTCoreTextLayoutFrame+DTRichText.h"
#import "DTMutableCoreTextLayoutFrame.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "DTMutableCoreTextLayoutFrame.h"
#import "NSDictionary+DTRichText.h"
#import "NSMutableDictionary+DTRichText.h"
#import "DTRichTextEditorView.h"

#import "DTTextPosition.h"
#import "DTTextRange.h"

#import "DTCursorView.h"
#import "DTLoupeView.h"
#import "DTCoreTextLayouter.h"

#import "DTTextSelectionView.h"
#import "CGUtils.h"
#import "DTCoreTextFontDescriptor.h"
#import "DTTiledLayerWithoutFade.h"

#import "DTWebArchive.h"
#import "NSAttributedString+DTWebArchive.h"
#import "NSAttributedStringRunDelegates.h"
#import "UIPasteboard+DTWebArchive.h"
#import "DTRichTextEditorContentView.h"


NSString * const DTRichTextEditorTextDidBeginEditingNotification = @"DTRichTextEditorTextDidBeginEditingNotification";


@interface DTRichTextEditorView ()

//@property (nonatomic, retain) NSMutableAttributedString *internalAttributedText;

@property (nonatomic, retain) DTLoupeView *loupe;
@property (nonatomic, retain) DTTextSelectionView *selectionView;

@property (nonatomic, readwrite) UITextRange *markedTextRange;  // internal property writeable

@property (nonatomic, retain) NSDictionary *overrideInsertionAttributes;
@property (nonatomic, retain) DTMutableCoreTextLayoutFrame *mutableLayoutFrame;

- (void)setDefaultText;
- (void)showContextMenuFromSelection;
- (void)hideContextMenu;

@end



@implementation DTRichTextEditorView
{
	BOOL _cursorIsShowing;
    NSDictionary *_textDefaults;
}

#pragma mark -
#pragma mark Initialization

+(void)initialize
{
#ifdef TIMEBOMB
#warning Timebomb enabled
	
	/*
	 NSTimeInterval expirationTimestamp = TIMEBOMB;
	 NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:expirationTimestamp];
	 */
	
	// stringification macros
#define xstr(s) str(s)
#define str(s) #s
	
	// TIMEBOMB is Jenkins build id = time
	char *buildid = xstr(TIMEBOMB);
	NSString *buildidStr = [NSString stringWithCString:buildid encoding:NSUTF8StringEncoding];
	
	// date formatter for parsing
	NSDateFormatter *pf = [[NSDateFormatter alloc] init];
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:60*60*2];
	[pf setDateFormat:@"yyyy-MM-dd_H-m-s"];
	[pf setTimeZone:tz];
	
	NSDate *buildDate = [pf dateFromString:buildidStr];
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:30];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *now = [NSDate date];
	NSDate *expirationDate = [gregorian dateByAddingComponents:comps toDate:now options:0];
	
	// date formatter for output
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setTimeStyle:NSDateFormatterNoStyle];
	[df setDateStyle:NSDateFormatterMediumStyle];
	
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
	_showsKeyboardWhenBecomingFirstResponder = YES;
	
	self.contentView.shouldLayoutCustomSubviews = YES;
	
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
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.contentView.edgeInsets = UIEdgeInsetsMake(20, 10, 10, 10);
	self.editable = YES;
    self.selectionAffinity = UITextStorageDirectionForward;
	self.userInteractionEnabled = YES; 	// for autocorrection candidate view
	
	// --- gestures
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
	
	//self.contentView.userInteractionEnabled = YES;
	self.selectionView.userInteractionEnabled = NO;
	// --- notifications
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(cursorDidBlink:) name:DTCursorViewDidBlink object:nil];
	[center addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
	[center addObserver:self selector:@selector(loupeDidHide:) name:DTLoupeDidHide object:nil];
	[center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
	if (![self.contentView.layoutFrame.attributedStringFragment length])
	{
		[self setDefaultText];
	}
	
	// this also layouts the content View
	[super layoutSubviews];
    
    [_selectionView layoutSubviewsInRect:self.bounds];
	
	if (self.isDragging || self.decelerating)
	{
		if ([_loupe isShowing] && _loupe.style == DTLoupeStyleCircle)
		{
			_loupe.seeThroughMode = YES;
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

#pragma mark Menu

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
	_contextMenuVisible = YES;
	
	CGRect targetRect;
	
	if ([_selectedTextRange length])
	{
		targetRect = [_selectionView selectionEnvelope];
	}
	else
	{
		targetRect = self.cursor.frame;
	}
	
	if (![self selectionIsVisible])
	{
		// don't show it
		return;
	}
	
	if (!self.isFirstResponder)
	{
		BOOL previousState = _showsKeyboardWhenBecomingFirstResponder;
		
		if (!_keyboardIsShowing)
		{
			// prevent keyboard from showing if it is not visible
			_showsKeyboardWhenBecomingFirstResponder = NO;
		}
		
		[self becomeFirstResponder];
		
		_showsKeyboardWhenBecomingFirstResponder = previousState;
	}
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	//	UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Item" action:@selector(menuItemClicked:)];
	
	//NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
	//[menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
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
- (void)scrollCursorVisibleAnimated:(BOOL)animated
{
	if  (![_selectedTextRange isEmpty] || !_cursorIsShowing)
	{
		return;
	}
	
	CGRect cursorFrame = [self caretRectForPosition:self.selectedTextRange.start];
    cursorFrame.size.width = 3.0;
	
	if (!_cursor.superview)
	{
		[self addSubview:_cursor];
	}
	
	UIEdgeInsets reverseInsets = self.contentView.edgeInsets;
	reverseInsets.top *= -1.0;
	reverseInsets.bottom *= -1.0;
	reverseInsets.left *= -1.0;
	reverseInsets.right *= -1.0;
	
	cursorFrame = UIEdgeInsetsInsetRect(cursorFrame, reverseInsets);
	
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		
		// this prevents multiple scrolling to same position
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	[self scrollRectToVisible:cursorFrame animated:NO];
	
	if (animated)
	{
		[UIView commitAnimations];
	}
}

- (void)_scrollCursorVisible
{
	[self scrollCursorVisibleAnimated:YES];
}

- (void)updateCursorAnimated:(BOOL)animated
{
	// re-add cursor
	DTTextPosition *position = (id)self.selectedTextRange.start;
	
	// no selection
	if (!position || !_cursorIsShowing)
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
		
		CGRect cursorFrame = [self caretRectForPosition:position];
		cursorFrame.size.width = 3.0;
		
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		self.cursor.frame = cursorFrame;
		[CATransaction commit];
		
		if (!_cursor.superview)
		{
			[self addSubview:_cursor];
		}
		
		[self _scrollCursorVisible];
	}
	else
	{
        // show as a blue selection range
		self.selectionView.style = DTTextSelectionStyleSelection;
		NSArray *rects = [self.contentView.layoutFrame  selectionRectsForRange:[_selectedTextRange NSRangeValue]];
		
		[_selectionView setSelectionRectangles:rects animated:animated];
		
		// no cursor
		[_cursor removeFromSuperview];
		
		return;
	}
	
	if (_markedTextRange)
	{
		self.selectionView.style = DTTextSelectionStyleMarking;
		NSArray *rects = [self.contentView.layoutFrame  selectionRectsForRange:[_markedTextRange NSRangeValue]];
		_selectionView.selectionRectangles = rects;
		
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
	DTTextPosition *position = (id)[self closestPositionToPoint:location];
	DTTextRange *wordRange = [self rangeForWordAtPosition:position];
	self.selectedTextRange = wordRange;
}


- (BOOL)moveCursorToPositionClosestToLocation:(CGPoint)location
{
	BOOL didMove = NO;
	
	[self.inputDelegate selectionWillChange:self];
	
	DTTextRange *constrainingRange = nil;
	
	if ([_markedTextRange length])
	{
		if ([self selectionIsVisible])
		{
			constrainingRange = _markedTextRange;
		}
	}
	else if ([_selectedTextRange length])
	{
		if ([self selectionIsVisible])
		{
			constrainingRange =_selectedTextRange;
		}
	}
	
	DTTextPosition *position = (id)[self closestPositionToPoint:location withinRange:constrainingRange];
	
	if (![(DTTextPosition *)_selectedTextRange.start isEqual:position] && ![(DTTextPosition *)_selectedTextRange.end isEqual:position])
	{
		// tap on same position
		didMove = YES;
	}
	
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
	
	[self.inputDelegate selectionDidChange:self];
	
	return didMove;
}


- (void)presentLoupeWithTouchPoint:(CGPoint)touchPoint
{
	_touchDownPoint = touchPoint;
	
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
		loupeStartPoint = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
		
		_dragCursorStartMidPoint = CGRectCenter(rect);
		
		self.loupe.style = DTLoupeStyleRectangleWithArrow;
		self.loupe.magnification = 0.5;
		self.loupe.touchPoint = loupeStartPoint;
		[self.loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	if (_dragMode == DTDragModeRightHandle)
	{
		CGPoint loupeStartPoint;
		
		CGRect rect = [_selectionView endCaretRect];
		loupeStartPoint = CGRectCenter(rect);
		_dragCursorStartMidPoint = CGRectCenter(rect);
		
		
		self.loupe.style = DTLoupeStyleRectangleWithArrow;
		self.loupe.magnification = 0.5;
		self.loupe.touchPoint = loupeStartPoint;
		self.loupe.touchPointOffset = CGPointMake(0, rect.origin.y - _dragCursorStartMidPoint.y);
		[self.loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	if (_dragMode == DTDragModeCursorInsideMarking)
	{
		
		self.loupe.style = DTLoupeStyleRectangleWithArrow;
		self.loupe.magnification = 0.5;
		
		CGPoint loupeStartPoint = CGRectCenter(_cursor.frame);
		
		self.loupe.touchPoint = loupeStartPoint;
		[self.loupe presentLoupeFromLocation:loupeStartPoint];
		
		return;
	}
	
	// normal round loupe
	self.loupe.style = DTLoupeStyleCircle;
	self.loupe.magnification = 1.2;
	
	if (self.editable)
	{
		[self moveCursorToPositionClosestToLocation:touchPoint];
	}
	else
	{
		[self selectWordAtPositionClosestToLocation:touchPoint];
		_selectionView.dragHandlesVisible = NO;
	}
	
	_loupe.touchPoint = touchPoint;
	[_loupe presentLoupeFromLocation:touchPoint];
	
	
}

- (void)moveLoupeWithTouchPoint:(CGPoint)touchPoint
{
	if (_dragMode == DTDragModeCursor)
	{
		_loupe.touchPoint = touchPoint;
		_loupe.seeThroughMode = NO;
		
		[self hideContextMenu];
		
		if (self.editable && _keyboardIsShowing)
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
		
		_loupe.touchPoint = CGRectCenter(_cursor.frame);
		_loupe.seeThroughMode = NO;
		
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
		[self setSelectedTextRange:newRange];
	}
	
	if (_dragMode == DTDragModeLeftHandle)
	{
		CGRect rect = [_selectionView beginCaretRect];
		CGPoint point = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
		self.loupe.touchPoint = point;
	}
	else if (_dragMode == DTDragModeRightHandle)
	{
		CGRect rect = [_selectionView endCaretRect];
		CGPoint point = CGRectCenter(rect);
		self.loupe.touchPoint = point;
	}
	
	
}

- (void)dismissLoupeWithTouchPoint:(CGPoint)touchPoint
{
	if (_dragMode == DTDragModeCursor || _dragMode == DTDragModeCursorInsideMarking)
	{
		if (self.editable)
		{
			if (_keyboardIsShowing)
			{
				[_loupe dismissLoupeTowardsLocation:self.cursor.center];
				_cursor.state = DTCursorStateBlinking;
			}
			else
			{
				[_loupe dismissLoupeTowardsLocation:touchPoint];
			}
		}
		else
		{
			CGRect rect = [_selectionView beginCaretRect];
			CGPoint point = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
			[_loupe dismissLoupeTowardsLocation:point];
		}
	}
	else if (_dragMode == DTDragModeLeftHandle)
	{
		CGRect rect = [_selectionView beginCaretRect];
		CGPoint point = CGRectCenter(rect);
		_shouldShowContextMenuAfterLoupeHide = YES;
		[_loupe dismissLoupeTowardsLocation:point];
	}
	else if (_dragMode == DTDragModeRightHandle)
	{
		_shouldShowContextMenuAfterLoupeHide = YES;
		CGRect rect = [_selectionView endCaretRect];
		CGPoint point = CGRectCenter(rect);
		[_loupe dismissLoupeTowardsLocation:point];
	}
	
	_dragMode = DTDragModeNone;	
}

- (void)removeMarkedTextCandidateView
{
	// remove invisible marking candidate view to avoid touch handling problems
	// prevents "Warning: phrase boundary gesture handler is somehow installed when there is no marked text"
	for (UIView *oneView in self.subviews)
	{
		if (![oneView isKindOfClass:[UIImageView class]] && oneView != contentView && oneView != _cursor && oneView != _selectionView)
		{
			[oneView removeFromSuperview];
		}
	}
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

#pragma mark Notifications

- (void)cursorDidBlink:(NSNotification *)notification
{
	// update loupe magnified image to show changed cursor
	if ([_loupe isShowing])
	{
		[_loupe setNeedsDisplay];
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
	
	// set inset to make up for covered array at bottom
	self.contentInset = UIEdgeInsetsMake(0, 0, coveredFrame.size.height, 0);
	self.scrollIndicatorInsets = self.contentInset;
	
	SEL selector = @selector(_scrollCursorVisible);
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
	[self performSelector:selector withObject:nil afterDelay:0.3];
	
	_keyboardIsShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	self.scrollIndicatorInsets = self.contentInset;
	
	_keyboardIsShowing = NO;
}


#pragma mark Gestures
- (void)handleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		if (self.editable)
		{
			// this mode has the drag handles showing
			self.selectionView.showsDragHandlesForSelection	= YES;
			
			// show the keyboard and cursor
			[self becomeFirstResponder];
			
			if (!_keyboardIsShowing && ![_selectedTextRange isEmpty])
			{
				[self resignFirstResponder];
				return;
			}
			
			CGPoint touchPoint = [gesture locationInView:self.contentView];
			
			if (!_markedTextRange)
			{
				if ([self moveCursorToPositionClosestToLocation:touchPoint])
				{
					// did move
					[self hideContextMenu];
				}
				else
				{
					// was same position as before
					[self showContextMenuFromSelection];
				}
			}
			[self unmarkText];
		}
		else
		{
			[self hideContextMenu];
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		CGPoint touchPoint = [gesture locationInView:self.contentView];
		
		DTTextPosition *position = (id)[self closestPositionToPoint:touchPoint withinRange:nil];
		
		DTTextRange *wordRange = [self rangeForWordAtPosition:position];
		
		self.selectionView.showsDragHandlesForSelection = _keyboardIsShowing;
		
		if (wordRange)
		{
			[self hideContextMenu];
			
			[self setSelectedTextRange:wordRange];
			_showsKeyboardWhenBecomingFirstResponder = NO;
			[self showContextMenuFromSelection];
			_showsKeyboardWhenBecomingFirstResponder = YES;
		}
	}
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture 
{
	CGPoint touchPoint = [gesture locationInView:self.contentView];
	
	switch (gesture.state) 
	{
		case UIGestureRecognizerStateBegan:
		{
			[self presentLoupeWithTouchPoint:touchPoint];
			_cursorIsShowing = YES;
			_cursor.state = DTCursorStateStatic;
		}
			
		case UIGestureRecognizerStateChanged:
		{
            _lastCursorMovementTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];
			[self moveLoupeWithTouchPoint:touchPoint];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			if (_dragMode != DTDragModeCursorInsideMarking)
			{
                NSTimeInterval delta = [[NSDate date] timeIntervalSinceReferenceDate] - _lastCursorMovementTimestamp;
                
                if (delta < 0.5)
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
                
				_shouldShowContextMenuAfterLoupeHide = YES;
                _selectionView.showsDragHandlesForSelection = YES;
			}
		}
			
		case UIGestureRecognizerStateCancelled:
		{
			[self dismissLoupeWithTouchPoint:touchPoint];
			
			break;
		}
			
		default:
		{
		}
	}
}


- (void)handleDragHandle:(UIPanGestureRecognizer *)gesture
{
	CGPoint touchPoint = [gesture locationInView:self.contentView];
	
	switch (gesture.state) 
	{
		case UIGestureRecognizerStateBegan:
		{
			[self presentLoupeWithTouchPoint:touchPoint];
			
			[self hideContextMenu];
			
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			[self moveLoupeWithTouchPoint:touchPoint];
            _lastCursorMovementTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
            NSTimeInterval delta = [[NSDate date] timeIntervalSinceReferenceDate] - _lastCursorMovementTimestamp;
            
            if (delta < 0.5)
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
			
			_shouldShowContextMenuAfterLoupeHide = YES;
			[self dismissLoupeWithTouchPoint:touchPoint];
		}
			
		default:
		{
			_dragMode = DTDragModeNone;
			
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
	
	if (hitView.superview == self && hitView != self.contentView)
	{
		return NO;
	}
	
	if (gestureRecognizer == longPressGesture)
	{
		//		if (![_selectionView dragHandlesVisible])
		//		{
		//			return YES;
		//		}
		
		//NSLog(@"%@ contains %@", NSStringFromCGRect(_selectionView.dragHandleLeft.frame), NSStringFromCGPoint(touchPoint));
		
		// selection and contentView have same coordinate system
		//		if (CGRectContainsPoint(_selectionView.dragHandleLeft.frame, touchPoint))
		//		{
		//			return NO;
		//		}
		//		else if (CGRectContainsPoint(_selectionView.dragHandleRight.frame, touchPoint))
		//		{
		//			return NO;
		//		}
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

#pragma mark -
#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	// selecting via long press does not show handles
	_selectionView.showsDragHandlesForSelection	= NO;
	
	_cursorIsShowing = NO;
	[self updateCursorAnimated:NO];
	[self hideContextMenu];
	
	return [super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	if (![self isFirstResponder] && [self canBecomeFirstResponder])
	{
        _cursorIsShowing = YES;
        
		if (_showsKeyboardWhenBecomingFirstResponder)
		{
			_keyboardIsShowing = YES;
            self.selectionView.showsDragHandlesForSelection = YES;
			
			// set curser to beginning of document if nothing selected
			if (!_selectedTextRange)
			{
				UITextPosition *begin = [self beginningOfDocument];
				self.selectedTextRange = [DTTextRange textRangeFromStart:begin toEnd:begin];
			}
		}
	}
	
	return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
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
        if (!_keyboardIsShowing)
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
        if (!_keyboardIsShowing)
        {
            return NO;
        }
		return YES;
	}
	
	if (action == @selector(copy:))
	{
		return YES;
	}
	
	
	return NO;
}

- (void)cut:(id)sender
{
	if ([_selectedTextRange isEmpty])
	{
		return;
	}
    
	// first step is identical with copy
	[self copy:sender];
	
	// second set is removing what was copied
	[self replaceRange:_selectedTextRange withText:@""];
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
	
	NSAttributedString *attributedString = [self.contentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:selectedRange];
	
	// plain text omits attachments and format
	NSString *plainText = [attributedString plainTextString];
	
	// web archive contains rich text
	DTWebArchive *webArchive = [attributedString webArchive];
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
	//	
	NSLog(@"%@", [pasteboard pasteboardTypes]);
	//	
	//	
	//	NSData *data = [pasteboard dataForPasteboardType:@"Apple Web Archive pasteboard type"];
	//	
	//	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	//	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"output.data"];
	//	[data writeToFile:path atomically:YES];
	
	//NSLog(@"%@", data);
	
	UIImage *image = [pasteboard image];
	
	//	if (image)
	//	{
	//		NSAttributedString *tmpString = [NSAttributedString attributedStringWithImage:image maxDisplaySize:_maxImageDisplaySize];
	//		[self replaceRange:_selectedTextRange withText:tmpString];
	//
	//		return;
	//	}
	
	if (image)
	{
		DTTextAttachment *attachment = [[DTTextAttachment alloc] init];
		attachment.contentType = DTTextAttachmentTypeImage;
		attachment.contentURL = [pasteboard URL];
		attachment.contents = image;
		attachment.originalSize = [image size];
		
		CGSize displaySize = image.size;
		if (!CGSizeEqualToSize(_maxImageDisplaySize, CGSizeZero))
		{
			if (_maxImageDisplaySize.width < image.size.width || _maxImageDisplaySize.height < image.size.height)
			{
				displaySize = sizeThatFitsKeepingAspectRatio2(image.size,_maxImageDisplaySize);
			}
		}
		attachment.displaySize = displaySize;
		
		[self replaceRange:_selectedTextRange withAttachment:attachment inParagraph:NO];
		
		return;
	}
	
	NSURL *url = [pasteboard URL];
	
	if (url)
	{
		NSAttributedString *tmpString = [NSAttributedString attributedStringWithURL:url];
		[self replaceRange:_selectedTextRange withText:tmpString];
		
		return;
	}
	
	
	DTWebArchive *webArchive = [pasteboard webArchive];
	
	if (webArchive)
	{
		NSAttributedString *attrString = [[NSAttributedString alloc] initWithWebArchive:webArchive options:[self textDefaults] documentAttributes:NULL];
		
		[self replaceRange:_selectedTextRange withText:attrString];
		
		return;
	}
	
	NSString *string = [pasteboard string];
	
	if (string)
	{
		[self replaceRange:_selectedTextRange withText:string];
	}
}

- (void)select:(id)sender
{
	DTTextPosition *currentPosition = (DTTextPosition *)[_selectedTextRange start];
	DTTextRange *wordRange = [self rangeForWordAtPosition:currentPosition];
	
	if (wordRange)
	{
		_shouldReshowContextMenuAfterHide = YES;
		
		self.selectionView.showsDragHandlesForSelection = _keyboardIsShowing;
		
		[self setSelectedTextRange:wordRange];
	}
}

- (void)selectAll:(id)sender
{
	_shouldReshowContextMenuAfterHide = YES;
	
	DTTextRange *fullRange = [DTTextRange textRangeFromStart:(DTTextPosition *)[self beginningOfDocument] toEnd:(DTTextPosition *)[self endOfDocument]];
	[self setSelectedTextRange:fullRange];
}

- (void)delete:(id)sender
{
	
}



#pragma mark UIKeyInput Protocol
- (BOOL)hasText
{
	return [self.contentView.layoutFrame.attributedStringFragment length]>0;
}

- (void)insertText:(NSString *)text
{
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
		[self replaceRange:self.markedTextRange withText:text];
		[self unmarkText];
	}
	else 
	{
		DTTextRange *selectedRange = (id)self.selectedTextRange;
		
		[self replaceRange:selectedRange withText:text];
		//[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[selectedRange start] offset:[text length]]];
		// leave marking intact
	}
	
	// hide context menu on inserting text
	[self hideContextMenu];
}

- (void)deleteBackward
{
	DTTextRange *currentRange = (id)[self selectedTextRange];
	
	if ([currentRange isEmpty])
	{
		// delete character left of carret
		
		DTTextPosition *delEnd = (DTTextPosition *)currentRange.start;
		DTTextPosition *docStart = (DTTextPosition *)[self beginningOfDocument];
		
		if ([docStart compare:delEnd] == NSOrderedAscending)
		{
			DTTextPosition *delStart = [DTTextPosition textPositionWithLocation:delEnd.location-1];
			DTTextRange *delRange = [DTTextRange textRangeFromStart:delStart toEnd:delEnd];
			
			[self replaceRange:delRange  withText:@""];
			//[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:delStart offset:0]];
		}
	}
	else 
	{
		// delete selection
		[self replaceRange:currentRange withText:nil];
		//	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[currentRange start] offset:0]];
	}
	
	// hide context menu on deleting text
	[self hideContextMenu];
}

#pragma mark UITextInput Protocol
#pragma mark -
#pragma mark Replacing and Returning Text

/* Methods for manipulating text. */
- (NSString *)textInRange:(UITextRange *)range
{
	NSString *bareText = [self.contentView.layoutFrame.attributedStringFragment string];
	DTTextRange *myRange = (DTTextRange *)range;
	NSRange rangeValue = [myRange NSRangeValue];
	
	// on iOS 5 the upper end of the range might be "unbounded" (NSIntegerMax)
	if (NSMaxRange(rangeValue)>[bareText length])
	{
		return [bareText substringFromIndex:rangeValue.location];
	}
	
	// otherwise return this part of the string			
	return [bareText substringWithRange:rangeValue];
}

- (void)replaceRange:(DTTextRange *)range withText:(id)text
{
	NSParameterAssert(range);
	
	NSRange myRange = [range NSRangeValue];
	
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
	
	DTCSSListStyle *effectiveList = [[typingAttributes objectForKey:DTTextListsAttribute] lastObject];
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
	
	NSMutableAttributedString *attributedString = (NSMutableAttributedString *)self.contentView.layoutFrame.attributedStringFragment;
	NSString *string = [attributedString string];
	
	// if we are in a list and just entered NL then we need appropriate list prefix
	if (effectiveList && newlineEntered)
	{
		if (myRange.length == 0)
		{
			NSRange paragraphRange = [string rangeOfParagraphAtIndex:myRange.location];
			NSString *paragraphString = [string substringWithRange:paragraphRange];
			
			NSUInteger itemNumber = [attributedString itemNumberInTextList:effectiveList atIndex:myRange.location];
			
			NSString *listPrefix = [effectiveList prefixWithCounter:itemNumber];
			
			NSMutableAttributedString *mutableParagraph = [[attributedString attributedSubstringFromRange:paragraphRange] mutableCopy];
			
			if ([paragraphString hasPrefix:listPrefix])
			{
				
				// check if it is an empty line, then we'll remove the list
				if (myRange.location == paragraphRange.location + [listPrefix length])
				{
					[mutableParagraph toggleListStyle:nil inRange:NSMakeRange(0, paragraphRange.length) numberFrom:0];
					
					text = mutableParagraph;
					myRange = paragraphRange;
					
					// adjust cursor position
					rangeToSelectAfterReplace.location -= [listPrefix length] + 1;
					
					
					// paragraph before gets its spacing back
					if (paragraphRange.location)
					{
						[attributedString toggleParagraphSpacing:YES atIndex:paragraphRange.location-1];
					}
				}
				else
				{
					NSInteger itemNumber = [attributedString itemNumberInTextList:effectiveList atIndex:myRange.location]+1;
					NSAttributedString *prefixAttributedString = [NSAttributedString prefixForListItemWithCounter:itemNumber listStyle:effectiveList listIndent:20 attributes:typingAttributes];
					
					// extend to include paragraph before in inserted string
					[mutableParagraph toggleParagraphSpacing:NO atIndex:0];
					
					// remove part after the insertion point
					NSInteger suffixLength = NSMaxRange(paragraphRange)-myRange.location;
					NSRange suffixRange = NSMakeRange(myRange.location - paragraphRange.location, suffixLength);
					[mutableParagraph deleteCharactersInRange:suffixRange];
					
					// adjust the insertion range to include the paragraph
					myRange.length += (myRange.location-paragraphRange.location);
					myRange.location = paragraphRange.location;
					
					// add the NL
					[mutableParagraph appendAttributedString:text];
					
					// append the new prefix
					[mutableParagraph appendAttributedString:prefixAttributedString];
					
					text = mutableParagraph;
					
					// adjust cursor position
					rangeToSelectAfterReplace.location += [prefixAttributedString length];
				}
			}
		}
	}
	
	[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:myRange withText:text];
	
	self.contentSize = self.contentView.frame.size;
	
    // if it's just one character remaining then set text defaults on this
    if ([[self.contentView.layoutFrame.attributedStringFragment string] isEqualToString:@"\n"])
    {
        NSDictionary *typingDefaults = [self defaultAttributes];
        
        [(NSMutableAttributedString *)self.contentView.layoutFrame.attributedStringFragment setAttributes:typingDefaults range:NSMakeRange(0, 1)];
    }
	
    // need to call extra because we control layouting
    [self setNeedsLayout];
	
	DTTextRange *selectedRange = [[DTTextRange alloc] initWithNSRange:rangeToSelectAfterReplace];
	[self setSelectedTextRange:selectedRange];
	
	[self updateCursorAnimated:NO];
	[self scrollCursorVisibleAnimated:YES];
	
	// send change notification
	[[NSNotificationCenter defaultCenter] postNotificationName:DTRichTextEditorTextDidBeginEditingNotification object:self userInfo:nil];
}

#pragma mark Working with Marked and Selected Text 
- (UITextRange *)selectedTextRange
{
	//	if (!_selectedTextRange)
	//	{
	//		// [inputDelegate selectionWillChange:self];
	//		DTTextPosition *begin = (id)[self beginningOfDocument];
	//		_selectedTextRange = [[DTTextRange alloc] initWithStart:begin end:begin];
	//		// [inputDelegate selectionDidChange:self];
	//	}
	
	return (id)_selectedTextRange;
}

- (void)setSelectedTextRange:(DTTextRange *)newTextRange animated:(BOOL)animated
{
	//self.selectionView.showsDragHandlesForSelection = _keyboardIsShowing;
	
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
	
	[self willChangeValueForKey:@"selectedTextRange"];
	
	_selectedTextRange = [newTextRange copy];
	
	[self updateCursorAnimated:animated];
	[self hideContextMenu];
	
	self.overrideInsertionAttributes = nil;
	
	[self didChangeValueForKey:@"selectedTextRange"];
}

- (void)setSelectedTextRange:(DTTextRange *)newTextRange
{
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
	NSUInteger adjustedContentLength = [self.contentView.layoutFrame.attributedStringFragment length];
	
	if (adjustedContentLength>0)
	{
		// preserve trailing newline at end of document
		adjustedContentLength--;
	}
	
	if (!markedText)
	{
		markedText = @"";
	}
	
	
	DTTextRange *currentMarkedRange = (id)self.markedTextRange;
	DTTextRange *currentSelection = (id)self.selectedTextRange;
	DTTextRange *replaceRange;
	
	if (currentMarkedRange)
	{
		// replace current marked text
		replaceRange = currentMarkedRange;
	}
	else 
	{
		if (!currentSelection)
		{
			replaceRange = [DTTextRange emptyRangeAtPosition:(id)[self endOfDocument] offset:0];
		}
		else 
		{
			replaceRange = currentSelection;
		}
		
	}
	
	// do the replacing
	[self replaceRange:replaceRange withText:markedText];
	
	// adjust selection
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:replaceRange.start offset:[markedText length]]];
	
	[self willChangeValueForKey:@"markedTextRange"];
	
	// selected range is always zero-based
	DTTextPosition *startOfReplaceRange = (DTTextPosition *)replaceRange.start;
	
	// set new marked range
	self.markedTextRange = [[DTTextRange alloc]  initWithNSRange:NSMakeRange(startOfReplaceRange.location, [markedText length])];
	
	[self updateCursorAnimated:NO];
	
	[self didChangeValueForKey:@"markedTextRange"];
}

- (NSDictionary *)markedTextStyle
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor greenColor], UITextInputTextColorKey, nil];
}



- (void)unmarkText
{
	if (!_markedTextRange)
	{
		return;
	}
	
	[inputDelegate textWillChange:self];
	
	self.markedTextRange = nil;
	
	[self updateCursorAnimated:NO];
	
	// calling selectionDidChange makes the input candidate go away
	[inputDelegate textDidChange:self];
	
	[self removeMarkedTextCandidateView];
}

@synthesize selectionAffinity = _selectionAffinity;

// overrides
@synthesize maxImageDisplaySize = _maxImageDisplaySize;
@synthesize defaultFontFamily = _defaultFontFamily;
@synthesize baseURL = _baseURL;
@synthesize textSizeMultiplier = _textSizeMultiplier;


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
		if (([position compare:end] == NSOrderedAscending))
		{
			return [DTTextPosition textPositionWithLocation:position.location+offset];
		}
		else 
		{
			return end;
		}
	}
	
	return position;
}

- (UITextPosition *)positionFromPosition:(DTTextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
	DTTextPosition *begin = (id)[self beginningOfDocument];
	DTTextPosition *end = (id)[self endOfDocument];
	
	switch (direction) 
	{
		case UITextLayoutDirectionRight:
		{
			if ([position location] < end.location)
			{
				return [DTTextPosition textPositionWithLocation:position.location+1];
			}
			
			break;
		}
		case UITextLayoutDirectionLeft:
		{
			if (position.location > begin.location)
			{
				return [DTTextPosition textPositionWithLocation:position.location-1];
			}
			
			break;
		}
		case UITextLayoutDirectionDown:
		{
			NSInteger newIndex = [self.contentView.layoutFrame indexForPositionDownwardsFromIndex:position.location offset:offset];
			
			if (newIndex>=0)
			{
				return [DTTextPosition textPositionWithLocation:newIndex];
			}
			else 
			{
				return [self endOfDocument];
			}
		}
		case UITextLayoutDirectionUp:
		{
			NSInteger newIndex = [self.contentView.layoutFrame indexForPositionUpwardsFromIndex:position.location offset:offset];
			
			if (newIndex>=0)
			{
				return [DTTextPosition textPositionWithLocation:newIndex];
			}
			else 
			{
				return [self beginningOfDocument];
			}
		}
	}
	
	return nil;
}

- (UITextPosition *)beginningOfDocument
{
	return [DTTextPosition textPositionWithLocation:0];
}

- (UITextPosition *)endOfDocument
{
	if ([self hasText])
	{
		return [DTTextPosition textPositionWithLocation:[self.contentView.layoutFrame.attributedStringFragment length]-1];
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
// TODO: How is this implemented correctly?
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
	return [self endOfDocument];
}

- (UITextRange *)characterRangeByExtendingPosition:(DTTextPosition *)position inDirection:(UITextLayoutDirection)direction
{
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
	return [self.contentView.layoutFrame firstRectForRange:[range NSRangeValue]];
}

- (CGRect)caretRectForPosition:(DTTextPosition *)position
{
	NSInteger index = position.location;
	
	DTCoreTextLayoutLine *layoutLine = [self.contentView.layoutFrame lineContainingIndex:index];
	
	CGRect caretRect = [self.contentView.layoutFrame cursorRectAtIndex:index];
	
	caretRect.size.height = layoutLine.frame.size.height;
	caretRect.origin.x = roundf(caretRect.origin.x);
	caretRect.origin.y = layoutLine.frame.origin.y;
	
	return caretRect;
}


- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
	NSInteger newIndex = [self.contentView.layoutFrame closestCursorIndexToPoint:point];
	
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
	NSInteger index = [self.contentView.layoutFrame closestCursorIndexToPoint:point];
	
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
- (NSDictionary *)textStylingAtPosition:(DTTextPosition *)position inDirection:(UITextStorageDirection)direction;
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
		ctStyles = [self.contentView.layoutFrame.attributedStringFragment attributesAtIndex:position.location-1 effectiveRange:NULL];
	}
	else
	{
		if (position.location>=[self.contentView.layoutFrame.attributedStringFragment length])
		{
			return nil;
		}
		
		ctStyles = [self.contentView.layoutFrame.attributedStringFragment attributesAtIndex:position.location effectiveRange:NULL];
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


#pragma mark Reconciling Text Position and Character Offset

#pragma mark Returning the Text Input View
- (UIView *)textInputView
{
	return (id)self;
}

// not needed because there is a 1:1 relationship between positions and index in string
//- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position withinRange:(UITextRange *)range
//{
//    
//}






#pragma mark Properties
- (void)setAttributedText:(NSAttributedString *)newAttributedText
{
	// setting new text should remove all selections
	[self unmarkText];
	
	// make sure that the selected text range stays valid
	BOOL needsAdjustSelection = NO;
	if (NSMaxRange([_selectedTextRange NSRangeValue]) > [newAttributedText length])
	{
		needsAdjustSelection = YES;
	}
	
	if (newAttributedText)
	{
		NSMutableAttributedString *tmpString = [newAttributedText mutableCopy];
		
		if (![[tmpString string] hasSuffix:@"\n"])
		{
			[tmpString appendString:@"\n"];
		}
		
		[super setAttributedString:tmpString];
		
		[self.contentView sizeToFit];
	}
	else
	{
		[self setDefaultText];
	}
    
    [self setNeedsLayout];
	
	if (needsAdjustSelection)
	{
		self.selectedTextRange = _selectedTextRange;
	}
}

- (NSAttributedString *)attributedText
{
	return self.contentView.layoutFrame.attributedStringFragment;
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
	
	self.selectionView.frame = self.contentView.frame;
	[self updateCursorAnimated:NO];
}

- (DTLoupeView *)loupe
{
	if (!_loupe)
	{
		_loupe = [[DTLoupeView alloc] initWithStyle:DTLoupeStyleCircle targetView:self.contentView];
	}
	
	return _loupe;
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
		_selectionView = [[DTTextSelectionView alloc] initWithTextView:self.contentView];
		[self addSubview:_selectionView];
	}
	
	return _selectionView;
}

- (NSAttributedString *)attributedString
{
	return self.contentView.layoutFrame.attributedStringFragment;
}

- (UIView *)inputView
{
	if (_keyboardIsShowing || _showsKeyboardWhenBecomingFirstResponder)
	{
		return _inputView;
	}
	
	return nil;
}

- (void)setInputView:(UIView *)inputView
{
	if (_inputView != inputView)
	{
		_inputView = inputView;
	}
}


- (UIView *)inputAccessoryView
{
	if (_keyboardIsShowing || _showsKeyboardWhenBecomingFirstResponder)
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

//@synthesize internalAttributedText = _internalAttributedText;

@synthesize markedTextStyle;

@synthesize markedTextRange = _markedTextRange;

@synthesize editable = _editable;

@synthesize inputView = _inputView;
@synthesize inputAccessoryView = _inputAccessoryView;

#pragma mark UITextInputTraits Protocol
@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardAppearance;
@synthesize keyboardType;
@synthesize returnKeyType;
@synthesize secureTextEntry;
//@synthesize spellCheckingType;

@synthesize loupe = _loupe;
@synthesize cursor = _cursor;
@synthesize selectionView = _selectionView;

@synthesize overrideInsertionAttributes = _overrideInsertionAttributes;

@synthesize canInteractWithPasteboard = _canInteractWithPasteboard;
@synthesize replaceParagraphsWithLineFeeds = _replaceParagraphsWithLineFeeds;
@synthesize mutableLayoutFrame = _mutableLayoutFrame;


@end

#pragma mark -
#pragma mark Manipulation Methods

@implementation DTRichTextEditorView (manipulation)

- (DTTextRange *)rangeForWordAtPosition:(DTTextPosition *)position
{
	DTTextRange *forRange = (id)[[self tokenizer] rangeEnclosingPosition:position withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
    DTTextRange *backRange = (id)[[self tokenizer] rangeEnclosingPosition:position withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
	
    if (forRange && backRange) 
	{
        DTTextRange *newRange = [DTTextRange textRangeFromStart:[backRange start] toEnd:[backRange end]];
		return newRange;
    }
	else if (forRange) 
	{
		return forRange;
    } 
	else if (backRange) 
	{
		return backRange;
    }
	
	// treat image as word, left side of image selects it
	NSAttributedString *characterString = [self.contentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:NSMakeRange(position.location, 1)];
	
	if ([[characterString attributesAtIndex:0 effectiveRange:NULL] objectForKey:NSAttachmentAttributeName])
	{
		return [DTTextRange textRangeFromStart:position toEnd:[position textPositionWithOffset:1]];
	}
	
	// we did not get a forward or backward range, like Word!|
	DTTextPosition *previousPosition = (id)([tokenizer positionFromPosition:position
																 toBoundary:UITextGranularityCharacter
																inDirection:UITextStorageDirectionBackward]);
	
	
	// treat image as word, right side of image selects it
	characterString = [self.contentView.layoutFrame.attributedStringFragment attributedSubstringFromRange:NSMakeRange(previousPosition.location, 1)];
	
	if ([[characterString attributesAtIndex:0 effectiveRange:NULL] objectForKey:NSAttachmentAttributeName])
	{
		return [DTTextRange textRangeFromStart:previousPosition toEnd:[previousPosition textPositionWithOffset:1]];
	}
	
	forRange = (id)[[self tokenizer] rangeEnclosingPosition:previousPosition withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
    backRange = (id)[[self tokenizer] rangeEnclosingPosition:previousPosition withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
	
	UITextRange *retRange = nil;
	
    if (forRange && backRange) 
	{
		retRange = [DTTextRange textRangeFromStart:[backRange start] toEnd:[backRange end]];
    }
	else if (forRange) 
	{
		retRange = forRange;
    } 
	else if (backRange) 
	{
		retRange = backRange;
    }
	
	// need to extend to include the previous position
	if (retRange)
	{
		// extend this range to go up to current position
		return [DTTextRange textRangeFromStart:[retRange start] toEnd:position];
	}
	
	return nil;
}


- (NSDictionary *)defaultAttributes
{
    NSDictionary *defaults = [self textDefaults];
    NSString *fontFamily = [defaults objectForKey:DTDefaultFontFamily];
    
    CGFloat multiplier = [[defaults objectForKey:NSTextSizeMultiplierDocumentOption] floatValue];
    
    if (!multiplier)
    {
        multiplier = 1.0;
    }
    
    DTCoreTextFontDescriptor *desc = [[DTCoreTextFontDescriptor alloc] init];
    desc.fontFamily = fontFamily;
    desc.pointSize = 12.0 * multiplier;
    
    CTFontRef defaultFont = [desc newMatchingFont];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [(NSMutableDictionary *)attributes setObject:(__bridge id)defaultFont forKey:(id)kCTFontAttributeName];
    
    CFRelease(defaultFont);  
    
    return attributes;
}

- (NSDictionary *)typingAttributesForRange:(DTTextRange *)range
{
	NSDictionary *attributes = [self.contentView.layoutFrame.attributedStringFragment typingAttributesForRange:[range NSRangeValue]];
	
	CTFontRef font = (__bridge CTFontRef)[attributes objectForKey:(id)kCTFontAttributeName];
	CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[attributes objectForKey:(id)kCTParagraphStyleAttributeName];
	
	if (font&&paragraphStyle)
	{
		return attributes;
	}
	
	// otherwise we need to add missing things
	
	NSDictionary *defaults = [self textDefaults];
	NSString *fontFamily = [defaults objectForKey:DTDefaultFontFamily];
	
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
        desc.pointSize = 12.0 * multiplier;
        
        CTFontRef defaultFont = [desc newMatchingFont];
        
        [tmpAttributes setObject:(__bridge id)defaultFont forKey:(id)kCTFontAttributeName];
        
        CFRelease(defaultFont);
	}
	
	if (!paragraphStyle)
	{
		DTCoreTextParagraphStyle *defaultStyle = [DTCoreTextParagraphStyle defaultParagraphStyle];
		defaultStyle.paragraphSpacing = 12.0 * multiplier;
		
		paragraphStyle = [defaultStyle createCTParagraphStyle];
		
		[tmpAttributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
		
		CFRelease(paragraphStyle);
	}
	
	return tmpAttributes;
}

- (UITextRange *)textRangeOfURLAtPosition:(UITextPosition *)position URL:(NSURL **)URL
{
	NSUInteger index = [(DTTextPosition *)position location];
	
	NSRange effectiveRange;
	
	NSURL *effectiveURL = [self.contentView.layoutFrame.attributedStringFragment attribute:DTLinkAttribute atIndex:index effectiveRange:&effectiveRange];
	
	if (!effectiveURL)
	{
		return nil;
	}
	
	DTTextRange *range = [[DTTextRange alloc] initWithNSRange:effectiveRange];
	
	if (URL)
	{
		*URL = effectiveURL;
	}
	
	return range;
}

- (void)replaceRange:(UITextRange *)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph
{
	NSRange textRange = [(DTTextRange *)range NSRangeValue];
	
	NSMutableDictionary *attributes = [[self typingAttributesForRange:range] mutableCopy];
	
	// just in case if there is an attachment at the insertion point
	[attributes removeAttachment];
	
	BOOL needsParagraphBefore = NO;
	BOOL needsParagraphAfter = NO;
	
	NSString *plainText = [self.contentView.layoutFrame.attributedStringFragment string];
	
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
	
	NSUInteger replacementLength = [tmpAttributedString length];
	
	// need to notify input delegate to remove autocorrection candidate view if present
	[inputDelegate textWillChange:self];
	
	[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:textRange withText:tmpAttributedString];
	
	[inputDelegate textDidChange:self];
	
	if (_keyboardIsShowing)
	{
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[range start] offset:replacementLength]];
	}
	else
	{
		[self setSelectedTextRange:nil animated:NO];
	}
	
	[self updateCursorAnimated:NO];
	
	// this causes the image to appear, layout gets the custom view for the image
	[self setNeedsLayout];
	
	// send change notification
	[[NSNotificationCenter defaultCenter] postNotificationName:DTRichTextEditorTextDidBeginEditingNotification object:self userInfo:nil];
}

- (void)toggleBoldInRange:(UITextRange *)range
{
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
		NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament bold
		[fragment toggleBoldInRange:NSMakeRange(0, [fragment length])];
		
		// replace 
		[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
		
		// cursor positions might have changed
		[self updateCursorAnimated:NO];
	}
	
	[self hideContextMenu];
}

- (void)toggleItalicInRange:(UITextRange *)range
{
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
		NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament bold
		[fragment toggleItalicInRange:NSMakeRange(0, [fragment length])];
		
		// replace 
		[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
		
		// attachment positions might have changed
		[self.contentView layoutSubviewsInRect:self.bounds];
		
		// cursor positions might have changed
		[self updateCursorAnimated:NO];
	}
	
	[self hideContextMenu];
}

- (void)toggleUnderlineInRange:(UITextRange *)range
{
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
		
		// get fragment that is to be made bold
		NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament bold
		[fragment toggleUnderlineInRange:NSMakeRange(0, [fragment length])];
		
		// replace 
		[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
		
		// attachment positions might have changed
		[self.contentView layoutSubviewsInRect:self.bounds];
		
		// cursor positions might have changed
		[self updateCursorAnimated:NO];
	}
	
	[self hideContextMenu];
}

- (void)toggleHighlightInRange:(UITextRange *)range color:(UIColor *)color
{
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
		NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
		
		// make entire frament highlighted
		[fragment toggleHighlightInRange:NSMakeRange(0, [fragment length]) color:[UIColor yellowColor]];
		
		// replace 
		[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
		
		// attachment positions might have changed
		[self.contentView layoutSubviewsInRect:self.bounds];
		
		// cursor positions might have changed
		[self updateCursorAnimated:NO];
	}
	
	[self hideContextMenu];
}

- (void)toggleHyperlinkInRange:(UITextRange *)range URL:(NSURL *)URL
{
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
	
	// get fragment that is to be made bold
	NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
	
	// make entire frament highlighted
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
	[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
	
	// attachment positions might have changed
	[self.contentView layoutSubviewsInRect:self.bounds];
	
	// cursor positions might have changed
	[self updateCursorAnimated:NO];

	[self hideContextMenu];
}


- (void)applyTextAlignment:(CTTextAlignment)alignment toParagraphsContainingRange:(UITextRange *)range
{
	NSRange styleRange = [(DTTextRange *)range NSRangeValue];
	
	// get range containing all selected paragraphs
	NSAttributedString *attributedString = [contentView.layoutFrame attributedStringFragment];
	
	NSString *string = [attributedString string];
	
	NSUInteger begIndex;
	NSUInteger endIndex;
	
	[string rangeOfParagraphsContainingRange:styleRange parBegIndex:&begIndex parEndIndex:&endIndex];
	styleRange = NSMakeRange(begIndex, endIndex - begIndex); // now extended to full paragraphs
	
	// get fragment that is to be changed
	NSMutableAttributedString *fragment = [[[contentView.layoutFrame attributedStringFragment] attributedSubstringFromRange:styleRange] mutableCopy];
	[fragment adjustTextAlignment:alignment inRange:NSMakeRange(0, [fragment length])];
	
	// replace 
	[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
	
	// attachment positions might have changed
	[self.contentView layoutSubviewsInRect:self.bounds];
	
	// cursor positions might have changed
	[self updateCursorAnimated:NO];
	
	[self hideContextMenu];
}

- (void)toggleListStyle:(DTCSSListStyle *)listStyle inRange:(UITextRange *)range
{
	NSRange styleRange = [(DTTextRange *)range NSRangeValue];
	
	NSRange rangeToSelectAfterwards = styleRange;
	
	// get range containing all selected paragraphs
	NSAttributedString *attributedString = [contentView.layoutFrame attributedStringFragment];
	
	NSString *string = [attributedString string];
	
	NSUInteger begIndex;
	NSUInteger endIndex;
	
	[string rangeOfParagraphsContainingRange:styleRange parBegIndex:&begIndex parEndIndex:&endIndex];
	styleRange = NSMakeRange(begIndex, endIndex - begIndex); // now extended to full paragraphs
	
	NSMutableAttributedString *entireAttributedString = (NSMutableAttributedString *)[contentView.layoutFrame attributedStringFragment];
	
	// check if we are extending a list
	DTCSSListStyle *extendingList = nil;
	NSInteger nextItemNumber;
	
	if (styleRange.location>0)
	{
		NSArray *lists = [entireAttributedString attribute:DTTextListsAttribute atIndex:styleRange.location-1 effectiveRange:NULL];
		
		extendingList = [lists lastObject];
		
		if (extendingList.type == listStyle.type)
		{
			listStyle = extendingList;
		}
	}
	
	if (extendingList)
	{
		nextItemNumber = [entireAttributedString itemNumberInTextList:extendingList atIndex:styleRange.location-1]+1;
	}
	else
	{
		nextItemNumber = [listStyle startingItemNumber];
	}
	
	// remember current markers
	[entireAttributedString addMarkersForSelectionRange:rangeToSelectAfterwards];
	
	// toggle the list style
	[entireAttributedString toggleListStyle:listStyle inRange:styleRange numberFrom:nextItemNumber];
	
	// selected range has shifted
	rangeToSelectAfterwards = [entireAttributedString markedRangeRemove:YES];
	
	// relayout range of entire list
	//NSRange listRange = [entireAttributedString rangeOfTextList:listStyle atIndex:styleRange.location];
	//[(DTRichTextEditorContentView *)self.contentView relayoutTextInRange:rangeToSelectAfterwards];
	[self.contentView relayoutText];
	
	// get fragment that is to be changed
	//	NSMutableAttributedString *fragment = [[entireAttributedString attributedSubstringFromRange:styleRange] mutableCopy];
	
	//	NSRange fragmentRange = NSMakeRange(0, [fragment length]);
	
	//	[fragment toggleListStyle:listStyle inRange:fragmentRange numberFrom:nextItemNumber];
	
	// replace 
	//	[(DTRichTextEditorContentView *)self.contentView replaceTextInRange:styleRange withText:fragment];
	
	//	styleRange.length = [fragment length];
	self.selectedTextRange = [[DTTextRange alloc] initWithNSRange:rangeToSelectAfterwards];
	
	// attachment positions might have changed
	[self.contentView layoutSubviewsInRect:self.bounds];
	
	// cursor positions might have changed
	[self updateCursorAnimated:NO];	
	
	[self hideContextMenu];
}

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate
{
	// update all attachments that matchin this URL (possibly multiple images with same size)
	return [self.contentView.layoutFrame textAttachmentsWithPredicate:predicate];
}

- (void)relayoutText
{
	[self.contentView relayoutText];
}

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

- (NSString *)plainTextForRange:(UITextRange *)range
{
	if (!range)
	{
		return nil;
	}
	
	NSRange textRange = [(DTTextRange *)range NSRangeValue];
	
	NSString *tmpString = [[self.contentView.layoutFrame.attributedStringFragment string] substringWithRange:textRange];
	
	tmpString = [tmpString stringByReplacingOccurrencesOfString:UNICODE_OBJECT_PLACEHOLDER withString:@""];
	
	return tmpString;
};


- (void)setHTMLString:(NSString *)string
{
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:data options:[self textDefaults] documentAttributes:NULL];
	
	[self setAttributedText:attributedString];
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
    
    if (_textSizeMultiplier)
    {
        [tmpDict setObject:[NSNumber numberWithFloat:_textSizeMultiplier] forKey:NSTextSizeMultiplierDocumentOption];
    }
    
    if (_defaultFontFamily)
    {
        [tmpDict setObject:_defaultFontFamily forKey:DTDefaultFontFamily];
    }
    else
    {
        [tmpDict setObject:@"Times New Roman" forKey:DTDefaultFontFamily];
    }
    
    
    // otherwise use set defaults
    return tmpDict;
}

- (void)setTextDefaults:(NSDictionary *)textDefaults
{
    if (_textDefaults != textDefaults)
    {
        _textDefaults = textDefaults;
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

- (CGRect)visibleContentRect
{
	CGRect rect = self.bounds;
	rect.size.height -= self.contentInset.bottom;
	
	return rect;
}

- (BOOL)selectionIsVisible
{
	CGRect visibleContentRect = [self visibleContentRect];
	
	CGRect targetRect;
	
	if ([_selectedTextRange length])
	{
		targetRect = [_selectionView selectionEnvelope];
	}
	else
	{
		targetRect = self.cursor.frame;
	}
	
	if (!CGRectIntersectsRect(visibleContentRect, targetRect))
	{
		return NO;
	}
	
	return YES;
}

- (BOOL)isEditable
{
	// return NO if we don't want keyboard to show e.g. context menu only on double tap
	return _editable && _showsKeyboardWhenBecomingFirstResponder;
}

@end

#pragma mark CoreText Functions

@implementation DTRichTextEditorView (CoreText)

- (NSUInteger)numberOfLayoutLines
{
	return [self.contentView.layoutFrame.lines count];
}

- (DTCoreTextLayoutLine *)layoutLineAtIndex:(NSUInteger)lineIndex
{
	return [self.contentView.layoutFrame.lines objectAtIndex:lineIndex];
}

- (DTCoreTextLayoutLine *)layoutLineContainingTextPosition:(DTTextPosition *)textPosition
{
	// get index
	NSUInteger index = textPosition.location;
	
	// get line from layout frame
	return [self.contentView.layoutFrame lineContainingIndex:index];
}

- (NSArray *)visibleLayoutLines
{
	CGRect visibleRect = self.bounds;
	
	return [self.contentView.layoutFrame linesVisibleInRect:visibleRect];
}

@end
