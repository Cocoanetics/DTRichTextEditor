//
//  DTRichTextEditorContentView.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 11/24/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorContentView.h"
#import "DTMutableCoreTextLayoutFrame.h"
#import "DTCoreTextLayoutFrame.h"
#import "DTTiledLayerWithoutFade.h"


// Commented code useful to find deadlocks
#define SYNCHRONIZE_START(lock) /* NSLog(@"LOCK: FUNC=%s Line=%d", __func__, __LINE__), */dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define SYNCHRONIZE_END(lock) dispatch_semaphore_signal(lock) /*, NSLog(@"UN-LOCK")*/;


@implementation DTRichTextEditorContentView

+ (Class)layerClass
{
    return [DTTiledLayerWithoutFade class];
}

- (void)_sendFinishLayoutNotification
{
    // trigger new layout if needed
    CGSize neededSize = [self intrinsicContentSize];
    
    CGRect optimalFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, neededSize.width, neededSize.height);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:optimalFrame] forKey:@"OptimalFrame"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTAttributedTextContentViewDidFinishLayoutNotification object:self userInfo:userInfo];
}


- (void)relayoutText
{
	// Make sure we actually have a superview before attempting to relayout the text.
	if (_layoutFrame)
	{
		// remove all links because they might have merged or split
		[self removeAllCustomViewsForLinks];
		
		if ([_attributedString length])
		{
			CGRect rect = UIEdgeInsetsInsetRect(self.bounds, _edgeInsets);
			rect.size.height = CGFLOAT_OPEN_HEIGHT; // necessary height set as soon as we know it.
			
			DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
			layoutFrame.frame = rect;
			
            [self _sendFinishLayoutNotification];
		}
		
		[self setNeedsDisplay];
		[self setNeedsLayout];
	}
}

- (DTCoreTextLayoutFrame *)layoutFrame
{
	dispatch_sync(self.layoutQueue, ^{
		if (!_layoutFrame)
		{
			CGRect rect = UIEdgeInsetsInsetRect(self.bounds, _edgeInsets);
			rect.size.height = CGFLOAT_OPEN_HEIGHT; // necessary height set as soon as we know it.
			
			_layoutFrame = [[DTMutableCoreTextLayoutFrame alloc] initWithFrame:rect attributedString:_attributedString];
			
			if (_attributedString)
			{
				[self sizeToFit];
				[self setNeedsLayout];
				[self setNeedsDisplay];
			}
		}
	});
	
	return _layoutFrame;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
	BOOL needsRelayout = NO;
	
	if (_attributedString != attributedString)
	{
		[layoutFrame setAttributedString:attributedString];
		
		_attributedString = layoutFrame.attributedStringFragment;
		
		// new layout invalidates all positions for custom views
		[self removeAllCustomViews];
		
		needsRelayout = YES;
	}
	
	if (needsRelayout)
	{
		[self relayoutText];
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
    // don't bother with layout if we are not visible yet
    if (!self.superview)
    {
        return;
    }
    
	// reduce frame by edgeinsets
	CGRect frameForLayout = UIEdgeInsetsInsetRect(frame, _edgeInsets);
	frameForLayout.size.height = CGFLOAT_OPEN_HEIGHT;
	
	[(DTMutableCoreTextLayoutFrame *)self.layoutFrame setFrame:frameForLayout];
}

// incremental layouting
- (void)relayoutTextInRange:(NSRange)range
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
	dispatch_sync(self.layoutQueue, ^{
		[layoutFrame relayoutTextInRange:range];
		
		// remove all link custom views
		[self removeAllCustomViewsForLinks];
	});
	
	// relayout / redraw
	[self setNeedsDisplay];
	
    [self _sendFinishLayoutNotification];
}

- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
    __block CGRect dirtyRect = self.bounds;
    
	dispatch_sync(self.layoutQueue, ^{
		[layoutFrame replaceTextInRange:range withText:text dirtyRect:&dirtyRect];
		
		// remove all link custom views
		[self removeAllCustomViewsForLinks];
	});
	
	// relayout / redraw
	[self setNeedsDisplayInRect:dirtyRect];
	
    [self _sendFinishLayoutNotification];
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
}

@end
