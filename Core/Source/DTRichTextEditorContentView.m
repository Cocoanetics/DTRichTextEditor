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


// Commented code useful to find deadlocks
#define SYNCHRONIZE_START(lock) /* NSLog(@"LOCK: FUNC=%s Line=%d", __func__, __LINE__), */dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#define SYNCHRONIZE_END(lock) dispatch_semaphore_signal(lock) /*, NSLog(@"UN-LOCK")*/;


@interface DTRichTextEditorContentView ()

- (void)removeAttachmentCustomViewsNoLongerInLayoutFrame;

@end


@implementation DTRichTextEditorContentView

- (void)relayoutText
{
	//SYNCHRONIZE_START(self.selfLock)
	{
		// Make sure we actually have a superview before attempting to relayout the text.
		if (self.superview) 
		{
			// update the layout
			//[(DTMutableCoreTextLayoutFrame*)self.layoutFrame relayoutText];
			
			// remove all links because they might have merged or split
			[self removeAllCustomViewsForLinks];
			
			if (_attributedString)
			{
				// triggers new layout
				[self sizeToFit];
				//            CGSize neededSize = [self sizeThatFits:self.bounds.size];
				
				// set frame to fit text preserving origin
				// call super to avoid endless loop
				//            [self willChangeValueForKey:@"frame"];
				//            super.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, neededSize.width, neededSize.height);
				//            [self didChangeValueForKey:@"frame"];
			}
			
			[self setNeedsDisplay];
			[self setNeedsLayout];
		}
	}
	//SYNCHRONIZE_END(self.selfLock)
}


- (DTCoreTextLayoutFrame *)layoutFrame
{
	if (!_layoutFrame)
	{
		SYNCHRONIZE_START(self.selfLock)
		{
			CGRect rect = UIEdgeInsetsInsetRect(self.bounds, edgeInsets);
			rect.size.height = CGFLOAT_OPEN_HEIGHT; // necessary height set as soon as we know it.
			
			_layoutFrame = [[DTMutableCoreTextLayoutFrame alloc] initWithFrame:rect attributedString:_attributedString];
			
			if (_attributedString)
			{
				[self sizeToFit];
				[self setNeedsLayout];
				[self setNeedsDisplay];
			}
		}
		SYNCHRONIZE_END(self.selfLock)
	}
	
	return _layoutFrame;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
	BOOL needsRelayout = NO;
	
	SYNCHRONIZE_START(self.selfLock)
	{
		if (_attributedString != attributedString)
		{
			[layoutFrame setAttributedString:attributedString];
			
			_attributedString = layoutFrame.attributedStringFragment;
			
			// new layout invalidates all positions for custom views
			[self removeAllCustomViews];
			
			needsRelayout = YES;
		}
	}
	SYNCHRONIZE_END(self.selfLock)
	
	if (needsRelayout)
	{
		[self relayoutText];
	}
}

- (void)layoutSubviews
{
	if (_needsRemoveObsoleteAttachmentViews)
	{
		_needsRemoveObsoleteAttachmentViews = NO;
	}	
	
	[super layoutSubviews];
}

- (void)setFrame:(CGRect)frame
{
	[self willChangeValueForKey:@"frame"];
	[super setFrame:frame];
	
	// reduce frame by edgeinsets
	CGRect frameForLayout = UIEdgeInsetsInsetRect(frame, edgeInsets);
	
	[(DTMutableCoreTextLayoutFrame *)self.layoutFrame setFrame:frameForLayout];
	[self didChangeValueForKey:@"frame"];
}

// incremental layouting
- (void)relayoutTextInRange:(NSRange)range
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
	SYNCHRONIZE_START(self.selfLock)
	{
		[layoutFrame relayoutTextInRange:range];
		
		// remove attachment custom views that are no longer needed
		[self setNeedsRemoveObsoleteAttachmentViews:YES];
		
		// remove all link custom views
		[self removeAllCustomViewsForLinks];
	}
	SYNCHRONIZE_END(self.selfLock)
	
	// relayout / redraw
	[self setNeedsDisplay];
	
	// size might have changed
    layoutFrame.shouldRebuildLines = NO;
	[self sizeToFit];
    layoutFrame.shouldRebuildLines = YES;
}

- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text
{
	DTMutableCoreTextLayoutFrame *layoutFrame = (DTMutableCoreTextLayoutFrame *)self.layoutFrame;
	
	SYNCHRONIZE_START(self.selfLock)
	{
		[layoutFrame replaceTextInRange:range withText:text];
		
		// remove attachment custom views that are no longer needed
		[self setNeedsRemoveObsoleteAttachmentViews:YES];
		
		// remove all link custom views
		[self removeAllCustomViewsForLinks];
	}
	SYNCHRONIZE_END(self.selfLock)
	
	// relayout / redraw
	[self setNeedsDisplay];
	
	// size might have changed
    layoutFrame.shouldRebuildLines = NO;
	[self sizeToFit];
    layoutFrame.shouldRebuildLines = YES;
}

- (void)removeAttachmentCustomViewsNoLongerInLayoutFrame
{
	NSArray *attachmentsInFrame = [self.layoutFrame textAttachments];
	
	NSMutableArray *attachmentKeys = [[customViewsForAttachmentsIndex allKeys] mutableCopy];
	
	// remove all keys that are still in frame
	for (DTTextAttachment *oneAttachment in [NSSet setWithArray:attachmentsInFrame])
	{
		NSNumber *indexKey = [NSNumber numberWithInteger:[oneAttachment hash]];
		
		[attachmentKeys removeObject:indexKey];
	}
	
	// any left over are no longer in the layout Frame, so we remove them
	if ([attachmentKeys count])
	{
		[self setNeedsDisplay];
	}
	
	for (NSNumber *oneKey in attachmentKeys)
	{
		UIView *customView = [customViewsForAttachmentsIndex objectForKey:oneKey];
		[customView removeFromSuperview];
		
		[customViewsForAttachmentsIndex removeObjectForKey:oneKey];
		[self.customViews removeObject:customView];
	}
	
}

#pragma mark Properties

@synthesize needsRemoveObsoleteAttachmentViews = _needsRemoveObsoleteAttachmentViews;

@end
