//
//  DTRichTextEditorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DTAttributedTextContentView.h"
#import "DTCoreTextLayoutFrame+DTRichText.h"
#import "NSMutableAttributedString+DTRichText.h"
#import "DTRichTextEditorView.h"

#import "DTTextPosition.h"
#import "DTTextRange.h"

#import "DTCursorView.h"
#import "DTCoreTextLayouter.h"

#import "DTLoupeView.h"
#import "DTTextSelectionView.h"
#import "CGUtils.h"
#import "UIView+DT.h"
#import "DTCoreTextFontDescriptor.h"

@interface DTRichTextEditorView ()

@property (nonatomic, retain) NSMutableAttributedString *internalAttributedText;

@property (nonatomic, retain) DTLoupeView *loupe;
@property (nonatomic, retain) DTTextSelectionView *selectionView;

@property (nonatomic, readwrite) UITextRange *markedTextRange;  // internal property writeable

- (DTTextRange *)rangeForWordAtPosition:(DTTextPosition *)position;

@end



@implementation DTRichTextEditorView

#pragma mark -
#pragma mark Initialization
- (void)setDefaults
{
	//[DTCoreTextLayoutFrame setShouldDrawDebugFrames:YES];
	
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
	self.editable = YES;
    self.selectionAffinity = UITextStorageDirectionForward;
	self.userInteractionEnabled = YES; 	// for autocorrection candidate view
	
	// --- gestures
	if (!tap)
	{
		tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		tap.delegate = self;
		[self addGestureRecognizer:tap];
	}
	
	//	//	
	//	//	UITapGestureRecognizer *doubletap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapped:)] autorelease];
	//	//	doubletap.numberOfTapsRequired = 2;
	//	//	doubletap.delegate = self;
	//	//	[self.contentView addGestureRecognizer:doubletap];
	
	//[DTCoreTextLayoutFrame setShouldDrawDebugFrames:YES];
	
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
	
	[_selectedTextRange release];
	[_markedTextRange release];
	[_loupe release];
	
	[_internalAttributedText release];
	[markedTextStyle release];
	
	[_cursor release];
	[_selectionView release];
	
	[longPressGesture release];
	[panGesture release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setDefaults];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//	UIView *hitView = [super hitTest:point withEvent:event];
//	//	UIView *hitView = [self.contentView hitTest:point withEvent:event];
//	
//	//	if (!hitView)
//	//	{
//	//		hitView = [super hitTest:point withEvent:event];
//	//	}
//	
//	// need to skip self hitTest or else we get an endless hitTest loop
//	return hitView;
//}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.isDragging && [_loupe isShowing] && _loupe.style == DTLoupeStyleCircle)
	{
		_loupe.seeThroughMode = YES;
	}
}

#pragma mark Menu

- (void)hideContextMenu
{
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	if ([menuController isMenuVisible])
	{
		[menuController setMenuVisible:NO animated:YES];
	}
}

- (void)showContextMenuFromSelection
{
	CGRect targetRect;
	
	if ([_selectedTextRange length])
	{
		targetRect = [_selectionView selectionEnvelope];
	}
	else
	{
		targetRect = self.cursor.frame;
	}
	
	if (!self.isFirstResponder)
	{
		[self becomeFirstResponder];
	}
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	
	UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Item" action:@selector(menuItemClicked:)];
	
	//NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
	//[menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
	[menuController setTargetRect:targetRect inView:self];
	[menuController setMenuVisible:YES animated:YES];
	
	[resetMenuItem release];
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

#pragma mark Custom Selection/Marking/Cursor
- (void)scrollCursorVisibleAnimated:(BOOL)animated
{
	if  (![_selectedTextRange isEmpty])
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

- (void)updateCursor
{
	// re-add cursor
	DTTextPosition *position = (id)self.selectedTextRange.start;
	
	// no selection
	if (!position)
	{
		// remove cursor
		[_cursor removeFromSuperview];
		
		// remove selection
		_selectionView.selectionRectangles = nil;
		
		return;
	}
	
	
	
	
	// single cursor
	if ([_selectedTextRange isEmpty])
	{
		_selectionView.dragHandlesVisible = NO;
		
		CGRect cursorFrame = [self caretRectForPosition:position];
		cursorFrame.size.width = 3.0;
		self.cursor.frame = cursorFrame;
		
		if (!_cursor.superview)
		{
			[self addSubview:_cursor];
		}
		
		[self scrollCursorVisibleAnimated:YES];
	}
	else
	{
		self.selectionView.style = DTTextSelectionStyleSelection;
		NSArray *rects = [self.contentView.layoutFrame  selectionRectsForRange:[_selectedTextRange NSRangeValue]];
		_selectionView.selectionRectangles = rects;
		
		if (self.editable)
		{
			_selectionView.dragHandlesVisible = YES;
		}
		else
		{
			_selectionView.dragHandlesVisible = NO;
		}
		
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


- (void)moveCursorToPositionClosestToLocation:(CGPoint)location
{
	[self.inputDelegate selectionWillChange:self];
	
	DTTextRange *constrainingRange = nil;
	
	if ([_markedTextRange length])
	{
		constrainingRange = _markedTextRange;
	}
	else if ([_selectedTextRange length])
	{
		constrainingRange =_selectedTextRange;
	}
	
	DTTextPosition *position = (id)[self closestPositionToPoint:location withinRange:constrainingRange];
	
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
	
	[self.inputDelegate selectionDidChange:self];
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
		_dragMode = DTDragModeCursor;
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
		
		if (self.editable)
		{
			[self moveCursorToPositionClosestToLocation:touchPoint];
		}
		else
		{
			[self selectWordAtPositionClosestToLocation:touchPoint];
		}
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
	if (_dragMode == DTDragModeCursor)
	{
		if (self.editable)
		{
			[_loupe dismissLoupeTowardsLocation:self.cursor.center];
			_cursor.state = DTCursorStateBlinking;
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
	
	[self performSelector:@selector(_scrollCursorVisible) withObject:nil afterDelay:0.3];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	self.scrollIndicatorInsets = self.contentInset;
}


#pragma mark Gestures
- (void)handleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		if (![self isFirstResponder] && [self canBecomeFirstResponder])
		{
			[self becomeFirstResponder];
		}
		
		if (self.editable)
		{
			CGPoint touchPoint = [gesture locationInView:self.contentView];
			[self moveCursorToPositionClosestToLocation:touchPoint];
		}
		
		
		[self unmarkText];
		
		[self hideContextMenu];
	}
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture 
{
	CGPoint touchPoint = [gesture locationInView:self.contentView];
	
	switch (gesture.state) 
	{
		case UIGestureRecognizerStateBegan:
		{
			if (![self isFirstResponder] && [self canBecomeFirstResponder])
			{
				[self becomeFirstResponder];
			}
			
			// selection and self have same coordinate system
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
			
			
			[self presentLoupeWithTouchPoint:touchPoint];
			_cursor.state = DTCursorStateStatic;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			[self moveLoupeWithTouchPoint:touchPoint];

			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			_shouldShowContextMenuAfterLoupeHide = YES;
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
			
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			[self moveLoupeWithTouchPoint:touchPoint];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			[self dismissLoupeWithTouchPoint:touchPoint];
		}
			
		default:
		{
			_dragMode = DTDragModeNone;
			
			break;
		}
	}
}



- (void)doubletapped:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		contentView.drawDebugFrames = !contentView.drawDebugFrames;
	}
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//	if (gestureRecognizer == panGesture && otherGestureRecognizer == longPressGesture)
//	{
//		return YES;
//	}
//
//	//NSLog(@"%@ - %@", [gestureRecognizer class], [otherGestureRecognizer class]);
//
//	return YES;		
//	
//}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//	if (gestureRecognizer == longPressGesture)
//	{
//		if (_dragMode == DTDragModeNone)
//		{
//			return YES;
//		}
//		else
//		{
//			return NO;
//		}
//	}
//	
//	if (gestureRecognizer == panGesture)
//	{
//		if (_dragMode == DTDragModeNone)
//		{
//			return YES;
//		}
//		else
//		{
//			return NO;
//		}
//	}
//	
//	
//	return YES;
//}

//

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	CGPoint touchPoint = [touch locationInView:self];	
	
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
	}
	
	//NSLog(@"YES");
	return YES;
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//	NSLog(@"simultaneous ====> %@ and %@", NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
//
//	return YES;
//}



#pragma mark -
#pragma mark Debugging
//- (void)addSubview:(UIView *)view
//{
//    NSLog(@"addSubview: %@", view);
//    [super addSubview:view];
//}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//	UIView *hitView = [super hitTest:point withEvent:event];
//	
//	NSLog(@"hitView: %@", hitView);
//	return hitView;
//}

#pragma mark -
#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	// this removes cursor and selections
	
	self.selectedTextRange = nil;
	return [super resignFirstResponder];
}

- (void)cut:(id)sender
{
    
}

- (void)copy:(id)sender
{
    
}

- (void)paste:(id)sender
{
    
}

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
	
	
	// we did not get a forward or backward range, like Word!|
	DTTextPosition *previousPosition = (id)([tokenizer positionFromPosition:position
																	 toBoundary:UITextGranularityWord 
																	inDirection:UITextStorageDirectionBackward]);
		
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

- (void)select:(id)sender
{
	DTTextPosition *currentPosition = (DTTextPosition *)[_selectedTextRange start];
	DTTextRange *wordRange = [self rangeForWordAtPosition:currentPosition];
	
	if (wordRange)
	{
		_shouldReshowContextMenuAfterHide = YES;
		
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
	
	if (action == @selector(paste:))
	{
		// TODO: check pasteboard if there is something contained that can be pasted here
		return NO;
	}
	
//	if (action == @selector(copy:))
//	{
//		if (![_selectedTextRange isEmpty])
//		{
//			return YES;
//		}
//		else
//		{
//			return NO;
//		}
//	}
	
	return NO;
}

#pragma mark UIKeyInput Protocol
- (BOOL)hasText
{
	return [_internalAttributedText length]>0;
}

- (void)insertText:(NSString *)text
{
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
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[selectedRange start] offset:[text length]]];
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
			[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:delStart offset:0]];
		}
	}
	else 
	{
		// delete selection
		[self replaceRange:currentRange withText:nil];
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[currentRange start] offset:0]];
	}
	
	// hide context menu on deleting text
	[self hideContextMenu];
}

#pragma mark -
#pragma mark UITextInput Protocol
#pragma mark -
#pragma mark Replacing and Returning Text

/* Methods for manipulating text. */
- (NSString *)textInRange:(UITextRange *)range
{
	NSString *bareText = [_internalAttributedText string];
	DTTextRange *myRange = (DTTextRange *)range;
	NSRange rangeValue = [myRange NSRangeValue];
	
	return [bareText substringWithRange:rangeValue];
}

- (NSDictionary *)typingAttributesForRange:(DTTextRange *)range
{
	return [self.internalAttributedText typingAttributesForRange:[range NSRangeValue]];
}

- (void)replaceRange:(DTTextRange *)range withAttachment:(DTTextAttachment *)attachment
{
	NSParameterAssert(range);
	
	[_internalAttributedText replaceRange:[range NSRangeValue] withAttachment:attachment];
	
	self.attributedString = _internalAttributedText;
	
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[range start] offset:1]];
	[self updateCursor];
}

- (void)toggleBoldStyleInRange:(UITextRange *)range
{
	// first character determines current boldness
	NSDictionary *currentAttributes = [self typingAttributesForRange:range];
	
	CTFontRef currentFont = (CTFontRef)[currentAttributes objectForKey:(id)kCTFontAttributeName];
	DTCoreTextFontDescriptor *typingFontDescriptor = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
	
	// need to replace name with family
	CFStringRef family = CTFontCopyFamilyName(currentFont);
	typingFontDescriptor.fontFamily = (NSString *)family;
	CFRelease(family);
	
	typingFontDescriptor.fontName = nil;
	
	
	DTTextPosition *start = (id)range.start;
	DTTextPosition *end = (id)range.end;
	
    NSRange validRange = NSMakeRange(start.location, end.location - start.location);
    
    NSRange attrRange;
    NSUInteger index=validRange.location;
    
    while (index < NSMaxRange(validRange)) 
    {
        NSMutableDictionary *attrs = [[self.internalAttributedText attributesAtIndex:index effectiveRange:&attrRange] mutableCopy];
		CTFontRef currentFont = (CTFontRef)[attrs objectForKey:(id)kCTFontAttributeName];
		DTCoreTextFontDescriptor *desc = [DTCoreTextFontDescriptor fontDescriptorForCTFont:currentFont];
		
		// need to replace name with family
		CFStringRef family = CTFontCopyFamilyName(currentFont);
		desc.fontFamily = (NSString *)family;
		CFRelease(family);
		
		desc.fontName = nil;
		
		desc.boldTrait = !typingFontDescriptor.boldTrait;
		CTFontRef newFont = [desc newMatchingFont];
		[attrs setObject:(id)newFont forKey:(id)kCTFontAttributeName];
		CFRelease(newFont);
		
		if (attrRange.location < validRange.location)
		{
			attrRange.length -= (validRange.location - attrRange.location);
			attrRange.location = validRange.location;
		}
		
		if (NSMaxRange(attrRange)>NSMaxRange(validRange))
		{
			attrRange.length = NSMaxRange(validRange) - attrRange.location;
		}
		
		[self.internalAttributedText setAttributes:attrs range:attrRange];
		
        index += attrRange.length;
    }
	
	self.attributedString = self.internalAttributedText;
	//[self.contentView relayoutText];
}

- (void)replaceRange:(DTTextRange *)range withText:(id)text
{
	NSParameterAssert(range);
	
	NSRange myRange = [range NSRangeValue];
	
	// otherwise this turns into zombie
	[[range retain] autorelease];
	
	if (!text)
	{
		// text could be nil, but that's not valid for replaceCharactersInRange
		text = @"";
	}
	
	if ([text isKindOfClass:[NSString class]])
	{
		NSDictionary *typingAttributes = [self typingAttributesForRange:range];	
		
		if ([typingAttributes objectForKey:@"DTTextAttachment"])
		{
			// has an attachment, we need a new dictionary
			
			NSMutableDictionary *tmpDict = [typingAttributes mutableCopy];
			
			[tmpDict removeObjectForKey:(id)kCTRunDelegateAttributeName];
			[tmpDict removeObjectForKey:@"DTAttachmentParagraphSpacing"];
			[tmpDict removeObjectForKey:@"DTTextAttachment"];
			
			text = [[[NSAttributedString alloc] initWithString:text attributes:tmpDict] autorelease];
			
			[tmpDict release];
		}
	}
	
	if ([text isKindOfClass:[NSString class]])
	{
		[self.internalAttributedText replaceCharactersInRange:myRange withString:text];
	}
	else if ([text isKindOfClass:[NSAttributedString class]])
	{
		[self.internalAttributedText replaceCharactersInRange:myRange withAttributedString:text];
	}
	
	self.attributedString = _internalAttributedText;
	
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[range start] offset:[text length]]];
	
	
	
	//	if (_internalAttributedText)
	//	{
	//		[_internalAttributedText replaceCharactersInRange:myRange withString:text];
	//		self.attributedString = _internalAttributedText;
	//		
	//		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:[range start] offset:[text length]]];
	//		//[self setSelectedTextRange:range];
	//	}
	//	else 
	//	{
	//		_internalAttributedText = [[NSMutableAttributedString alloc] initWithString:text];
	//		self.attributedString = _internalAttributedText;
	//		
	//		// makes passed range a zombie!
	//		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)[self beginningOfDocument] offset:[text length]]];
	//	}
	
	[self updateCursor];
	[self scrollCursorVisibleAnimated:YES];
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

- (void)setSelectedTextRange:(DTTextRange *)newTextRange
{
	if (_selectedTextRange != newTextRange)
	{
		[self willChangeValueForKey:@"selectedTextRange"];
		[_selectedTextRange release];
		
		_selectedTextRange = [newTextRange copy];
		
		[self updateCursor];
		
		[self didChangeValueForKey:@"selectedTextRange"];
	}
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
	NSUInteger adjustedContentLength = [_internalAttributedText length];
	
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
	self.markedTextRange = [[[DTTextRange alloc]  initWithNSRange:NSMakeRange(startOfReplaceRange.location, [markedText length])] autorelease];
	
	[self updateCursor];
	
	[self didChangeValueForKey:@"markedTextRange"];
}

- (NSDictionary *)markedTextStyle
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor greenColor], UITextInputTextColorKey, nil];
}


- (void)unmarkText
{
	[inputDelegate selectionWillChange:self];

	self.markedTextRange = nil;
	
	[self updateCursor];
	
	// calling selectionDidChange makes the input candidate go away

	[inputDelegate selectionDidChange:self];
}

@synthesize selectionAffinity = _selectionAffinity;



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
			return [DTTextPosition textPositionWithLocation:position.location+offset];
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
		return [DTTextPosition textPositionWithLocation:[_internalAttributedText length]-1];
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
	CGRect caretRect = [self.contentView.layoutFrame frameOfGlyphAtIndex:index];
	
	caretRect.origin.x = roundf(caretRect.origin.x);
	caretRect.origin.y = roundf(caretRect.origin.y);
	
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
		return nil;
	
	if ([position isEqual:(id)[self endOfDocument]])
	{
		direction = UITextStorageDirectionBackward;
	}
	
	NSDictionary *ctStyles;
	if (direction == UITextStorageDirectionBackward && index > 0)
	{
		ctStyles = [_internalAttributedText attributesAtIndex:position.location-1 effectiveRange:NULL];
	}
	else
	{
		if (position.location>=[_internalAttributedText length])
		{
			return nil;
		}
		
		ctStyles = [_internalAttributedText attributesAtIndex:position.location effectiveRange:NULL];
	}
	
	/* TODO: Return typingAttributes, if position is the same as the insertion point? */
	
	NSMutableDictionary *uiStyles = [ctStyles mutableCopy];
	[uiStyles autorelease];
	
	CTFontRef ctFont = (CTFontRef)[ctStyles objectForKey:(id)kCTFontAttributeName];
	if (ctFont) 
	{
		/* As far as I can tell, the name that UIFont wants is the PostScript name of the font. (It's undocumented, of course. RADAR 7881781 / 7241008) */
		CFStringRef fontName = CTFontCopyPostScriptName(ctFont);
		UIFont *uif = [UIFont fontWithName:(id)fontName size:CTFontGetSize(ctFont)];
		CFRelease(fontName);
		[uiStyles setObject:uif forKey:UITextInputTextFontKey];
	}
	
	CGColorRef cgColor = (CGColorRef)[ctStyles objectForKey:(id)kCTForegroundColorAttributeName];
	if (cgColor)
		[uiStyles setObject:[UIColor colorWithCGColor:cgColor] forKey:UITextInputTextColorKey];
	
	if (self.backgroundColor)
		[uiStyles setObject:self.backgroundColor forKey:UITextInputTextBackgroundColorKey];
	
	return uiStyles;
}


#pragma mark Reconciling Text Position and Character Offset

#pragma mark Returning the Text Input View
- (UIView *)textInputView
{
	return (id)self.contentView;
}

// not needed because there is a 1:1 relationship between positions and index in string
//- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position withinRange:(UITextRange *)range
//{
//    
//}






#pragma mark Properties
- (void)setAttributedText:(NSAttributedString *)newAttributedText
{
	self.internalAttributedText = [[newAttributedText mutableCopy] autorelease];
}

- (void)setInternalAttributedText:(NSMutableAttributedString *)newAttributedText
{
	[_internalAttributedText autorelease];
	
	_internalAttributedText = [newAttributedText retain];
	
	self.contentView.edgeInsets = UIEdgeInsetsMake(20, 10, 10, 10);
	self.attributedString = _internalAttributedText;
	[self.contentView relayoutText];
	
	//[self updateCursor];
}

- (NSAttributedString *)attributedText
{
	return [[[NSAttributedString alloc] initWithAttributedString:_internalAttributedText] autorelease];
}

#pragma mark Properties

- (void)setMarkedTextRange:(UITextRange *)markedTextRange
{
	if (markedTextRange != _markedTextRange)
	{
		[self willChangeValueForKey:@"markedTextRange"];
		
		[_markedTextRange release];
		_markedTextRange = [markedTextRange copy];

		[self didChangeValueForKey:@"markedTextRange"];
	}
}

- (void)setContentSize:(CGSize)newContentSize
{
	[super setContentSize:newContentSize];
	
	self.selectionView.frame = self.contentView.frame;
	[self updateCursor];
	
	
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
		[self.contentView addSubview:_cursor];
	}
	
	return _cursor;
}

- (DTTextSelectionView *)selectionView
{
	if (!_selectionView)
	{
		_selectionView = [[DTTextSelectionView alloc] initWithTextView:self.contentView];
		[self.contentView addSubview:_selectionView];
	}
	
	return _selectionView;
}

- (NSMutableAttributedString *)internalAttributedText
{
	if (!_internalAttributedText)
	{
		_internalAttributedText = [[NSMutableAttributedString alloc] init];
	}
	
	return _internalAttributedText;
}



@synthesize internalAttributedText = _internalAttributedText;

@synthesize markedTextStyle;

@synthesize markedTextRange = _markedTextRange;

@synthesize editable = _editable;


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



@end


@implementation DTRichTextEditorView (manipulation)

- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate
{
	// update all attachments that matchin this URL (possibly multiple images with same size)
	return [self.contentView.layoutFrame textAttachmentsWithPredicate:predicate];
}

- (void)relayoutText
{
	[self.contentView relayoutText];
}

@end
