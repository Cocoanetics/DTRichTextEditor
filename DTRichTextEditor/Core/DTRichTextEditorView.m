//
//  DTRichTextEditorView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DTAttributedTextContentView.h"

#import "DTRichTextEditorView.h"

#import "DTTextPosition.h"
#import "DTTextRange.h"

#import "DTCursorView.h"
#import "DTCoreTextLayouter.h"

#import "DTCoreTextLayoutFrame+DTRichText.h"

#import "DTLoupeView.h"

@interface DTRichTextEditorView ()

@property (nonatomic, retain) NSMutableAttributedString *internalAttributedText;
@property (nonatomic, retain) CALayer *selectionLayer;
@property (nonatomic, retain) CALayer *markLayer;

@property (nonatomic, retain) DTLoupeView *loupe;

@end



@implementation DTRichTextEditorView

#pragma mark -
#pragma mark Initialization
- (void)setDefaults
{
    self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.enablesReturnKeyAutomatically = NO;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.secureTextEntry = NO;
 //   self.spellCheckingType = UITextSpellCheckingTypeYes;
    
    self.selectionAffinity = UITextStorageDirectionForward;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cursorDidBlink:) name:DTCursorViewDidBlink object:nil];
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
	[selectionLayer release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setDefaults];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.editable = YES;
    self.selectionAffinity = UITextStorageDirectionForward;
    // experiment: should be provided
	tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
	tap.delegate = self;
	[self.contentView addGestureRecognizer:tap];
	
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[self.contentView addGestureRecognizer:longPress];
	[longPress release];
	
//	
//	UITapGestureRecognizer *doubletap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapped:)] autorelease];
//	doubletap.numberOfTapsRequired = 2;
//	doubletap.delegate = self;
//	[self.contentView addGestureRecognizer:doubletap];
	
	
    self.backgroundColor = [UIColor whiteColor];
	
	self.clipsToBounds = YES;
	self.textDelegate = self;
    self.scrollEnabled = NO; 
	
	// for autocorrection candidate view
	self.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark Custom Selection/Marking/Cursor
- (void)updateCursor
{
	// re-add cursor
	DTTextPosition *position = (id)self.selectedTextRange.start;
	
	if (!position || ![_selectedTextRange isEmpty])
	{
		[_cursor removeFromSuperview];
		return;
	}
	
	CGRect cursorFrame = [self caretRectForPosition:self.selectedTextRange.start];
    cursorFrame.size.width = 3.0;
	
	if (!_cursor)
	{
		self.cursor = [[[DTCursorView alloc] initWithFrame:cursorFrame] autorelease];
	}
	
	self.cursor.frame = cursorFrame;
	[self.contentView addSubview:_cursor];
	
	[self scrollRectToVisible:cursorFrame animated:YES];
}

- (void)moveCursorToPositionClosestToLocation:(CGPoint)location
{
	[self.inputDelegate selectionWillChange:self];
	
	if (!self.markedTextRange)
	{
		DTTextPosition *position = (id)[self closestPositionToPoint:location];
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
	}
	else 
	{
		DTTextPosition *position = (id)[self closestPositionToPoint:location];
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
	}
	
	[self.inputDelegate selectionDidChange:self];
}

#pragma mark -
#pragma mark Debugging
- (void)addSubview:(UIView *)view
{
    NSLog(@"addSubview: %@", view);
    [super addSubview:view];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	
	NSLog(@"hitView: %@", hitView);
	return hitView;
}

#pragma mark -
#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder
{
	return YES;
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

- (void)select:(id)sender
{
    
}

- (void)selectAll:(id)sender
{
    
}

- (void)delete:(id)sender
{
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return YES;
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
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)selectedRange.start offset:[text length]]];
		// leave marking intact
	}
}
	
- (void)deleteBackward
{
	DTTextRange *currentRange = (id)[self selectedTextRange];
	
	if ([currentRange isEmpty])
	{
		// delete character left of carret
		
		DTTextPosition *delEnd = (id)currentRange.start;
		DTTextPosition *docStart = (id)[self beginningOfDocument];
		
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
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)currentRange.start offset:0]];
	}
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

- (void)replaceRange:(DTTextRange *)range withText:(NSString *)text
{
	NSRange myRange = [range NSRangeValue];
    
    [range retain];
    
	if (!text)
	{
		// text could be nil, but that's not valid for replaceCharactersInRange
		text = @"";
	}
	
	if (_internalAttributedText)
	{
		[_internalAttributedText replaceCharactersInRange:myRange withString:text];
		self.attributedString = _internalAttributedText;
		
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)range.start offset:[text length]]];
		//[self setSelectedTextRange:range];
	}
	else 
	{
		_internalAttributedText = [[NSMutableAttributedString alloc] initWithString:text];
		self.attributedString = _internalAttributedText;
        
        // makes passed range a zombie!
		[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)[self beginningOfDocument] offset:[text length]]];
	}
	
	[self updateCursor];
	
	if (myRange.length>1)
	{
		//´[inputDelegate textDidChange:self];
	}
}

#pragma mark Working with Marked and Selected Text 
- (UITextRange *)selectedTextRange
{
	if (!_selectedTextRange)
	{
       // [inputDelegate selectionWillChange:self];
		DTTextPosition *begin = (id)[self beginningOfDocument];
		_selectedTextRange = [[DTTextRange alloc] initWithStart:begin end:begin];
       // [inputDelegate selectionDidChange:self];
	}
	
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
        
        [self.selectionLayer setNeedsDisplay];
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
	[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:(id)replaceRange.start offset:[markedText length]]];
    
	[self willChangeValueForKey:@"markedTextRange"];
	
	// selected range is always zero-based
	DTTextPosition *startOfReplaceRange = (id)replaceRange.start;
    
	// set new marked range
	[_markedTextRange release];
	_markedTextRange = [[DTTextRange alloc] initWithNSRange:NSMakeRange(startOfReplaceRange.location, [markedText length])];
	
	[self.markLayer setNeedsDisplay];
	
	[self didChangeValueForKey:@"markedTextRange"];
}

- (NSDictionary *)markedTextStyle
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[UIColor greenColor], UITextInputTextColorKey, nil];
}

- (void)unmarkText
{
	[_markedTextRange release];
	_markedTextRange = nil;
	
	[markLayer setNeedsDisplay];
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


// called when marked text is showing
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(DTTextRange *)range
{
	DTTextPosition *position = (id)[self closestPositionToPoint:point];
	
	if ([position compare:(id)range.start] == NSOrderedAscending)
	{
		return range.start;
	}
	
	if ([position compare:(id)range.end] == NSOrderedDescending)
	{
		return range.end;
	}
	
	return position;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    NSInteger index = [self.contentView.layoutFrame closestIndexToPoint:point];
    
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
        ctStyles = [_internalAttributedText attributesAtIndex:position.location-1 effectiveRange:NULL];
    else
        ctStyles = [_internalAttributedText attributesAtIndex:position.location effectiveRange:NULL];
    
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
	
	
	self.attributedString = _internalAttributedText;
	[self.contentView relayoutText];
	
	//[self updateCursor];
}

- (NSAttributedString *)attributedText
{
	return [[[NSAttributedString alloc] initWithAttributedString:_internalAttributedText] autorelease];
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
	NSInteger newIndex = [self.contentView.layoutFrame closestIndexToPoint:point];
	
	return [DTTextPosition textPositionWithLocation:newIndex];
}

#pragma mark Gestures
- (void)tapped:(UITapGestureRecognizer *)gesture
{
	
	CGPoint point = [gesture locationInView:self.contentView];
	UIView *hitView = [self.contentView hitTest:point withEvent:nil];
	
	NSLog(@"%@", hitView);
	
//	if (hitView != self.contentView)
//	{
//		// cause cancelling of this gesture
//
//		gesture.enabled = NO; 
//		gesture.enabled = YES;
//		return;
//		
//	}
	
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		if (![self isFirstResponder] && [self canBecomeFirstResponder])
		{
			[self becomeFirstResponder];
			//gesture.enabled = NO;
		}
		
		
		
		
		//if (hitView == self.contentView)
		{
			NSLog(@"tapped");
			
			[self.inputDelegate selectionWillChange:self];

			if (!self.markedTextRange)
			{
				DTTextPosition *position = (id)[self closestPositionToPoint:[gesture locationInView:self.contentView]];
				[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
			}
			else 
			{
				DTTextPosition *position = (id)[self closestPositionToPoint:[gesture locationInView:self.contentView] withinRange:self.markedTextRange];
				[self setSelectedTextRange:[DTTextRange emptyRangeAtPosition:position offset:0]];
			}

			
			//[self unmarkText];
		
		[self.inputDelegate selectionDidChange:self];
			
		//	[inputDelegate textWillChange:self];
		//	[inputDelegate textDidChange:self];
			
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture 
{
    CGPoint touchPoint = [gesture locationInView:self.contentView];
	
	switch (gesture.state) 
	{
		case UIGestureRecognizerStateBegan:
		{
			self.loupe.style = DTLoupeStyleCircle;
			
			// The Initial TouchPoint needs to be set before we set the style
			_loupe.touchPoint = touchPoint;
			
			[_loupe presentLoupeFromLocation:touchPoint];
			
			_cursor.state = DTCursorStateStatic;
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			// Show Cursor and position between glyphs
			_loupe.touchPoint = touchPoint;
			
			[self moveCursorToPositionClosestToLocation:touchPoint];
			
			break;
		}
			
		default:
		{
			[_loupe dismissLoupeTowardsLocation:touchPoint];

			_cursor.state = DTCursorStateBlinking;
			
			break;
		}
	}
}

//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//	if (gestureRecognizer == tap)
//	{
//		if ([tap view] == self.contentView)
//		{
//			return YES;
//		}
//		
//		return NO;
//	}
//	
//	return YES;
//}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//	NSLog(@"simultaneous ====> %@ and %@", NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
//
//	return YES;
//}

#pragma mark Layer drawing
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx
{
	if (layer == selectionLayer)
	{
		if (!_selectedTextRange)
		{
			// no selection to draw
			return;
		}

		NSArray *rects = [self.contentView.layoutFrame  selectionRectsForRange:[_selectedTextRange NSRangeValue]];
		
		CGContextSetRGBFillColor(ctx, 0, 0.338, 0.652, 0.204);
		
		for (NSValue *value in rects)
		{
			CGRect rect = [value CGRectValue];
			CGContextFillRect(ctx, rect);
		}
	}
	else if (layer == markLayer)
	{
			if (!_markedTextRange)
			{
				// no selection to draw
				return;
			}
			
			NSArray *rects = [self.contentView.layoutFrame selectionRectsForRange:[_markedTextRange NSRangeValue]];
			
			CGContextSetRGBFillColor(ctx, 0, 0.652, 0.338, 0.204);
			
			for (NSValue *value in rects)
			{
				CGRect rect = [value CGRectValue];
				CGContextFillRect(ctx, rect);
			}
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


#pragma mark Properties

- (void)setContentSize:(CGSize)newContentSize
{
	[super setContentSize:newContentSize];
	
	// adjust the layers so that the entire selection is visible
	markLayer.frame = self.contentView.bounds;
	selectionLayer.frame = self.contentView.bounds;
}

- (CALayer *)selectionLayer
{
	if (!selectionLayer)
	{
		selectionLayer = [[CALayer alloc ]init];
		selectionLayer.frame = self.bounds;
		[self.layer addSublayer:selectionLayer];
		selectionLayer.delegate = self;
	}
	
	return selectionLayer;
}

- (CALayer *)markLayer
{
	if (!markLayer)
	{
		markLayer = [[CALayer alloc ]init];
		markLayer.frame = self.bounds;
		[self.layer addSublayer:markLayer];
		markLayer.delegate = self;
	}
	
	return markLayer;
}

- (DTLoupeView *)loupe
{
	if (!_loupe)
	{
		_loupe = [[DTLoupeView alloc] initWithStyle:DTLoupeStyleCircle targetView:self.contentView];
	}
	
	return _loupe;
}

@synthesize internalAttributedText = _internalAttributedText;

@synthesize markedTextStyle;

@synthesize markedTextRange = _markedTextRange;

@synthesize selectionLayer;
@synthesize markLayer;
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



@end
