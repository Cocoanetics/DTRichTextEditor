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

@interface DTRichTextEditorContentView ()

- (void)removeAttachmentCustomViewsNoLongerInLayoutFrame;

@end

@implementation DTRichTextEditorContentView

- (void)relayoutText
{
//	SYNCHRONIZE_START(self.layoutLock)
	{
		// Make sure we actually have a superview before attempting to relayout the text.
		if (self.superview) 
		{
			// update the layout
			[(DTMutableCoreTextLayoutFrame*)self.layoutFrame relayoutText];
			
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
//	SYNCHRONIZE_END(self.layoutLock)
}


- (DTCoreTextLayoutFrame *)layoutFrame
{
//	SYNCHRONIZE_START(self.layoutLock)
	{
		if (!_layoutFrame)
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
	}
//	SYNCHRONIZE_END(self.layoutLock)
	
	return _layoutFrame;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	if (_attributedString != attributedString)
	{
		[_attributedString release];
		
		[(DTMutableCoreTextLayoutFrame *)self.layoutFrame setAttributedString:attributedString];
		
		_attributedString = [self.layoutFrame.attributedStringFragment retain];
		
		// new layout invalidates all positions for custom views
		[self removeAllCustomViews];
		
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
- (void)replaceTextInRange:(NSRange)range withText:(NSAttributedString *)text
{
//	SYNCHRONIZE_START(self.layoutLock)
	{
		[(DTMutableCoreTextLayoutFrame *)self.layoutFrame replaceTextInRange:range withText:text];
		
		// remove attachment custom views that are no longer needed
		[self setNeedsRemoveObsoleteAttachmentViews:YES];
		
		// remove all link custom views
		[self removeAllCustomViewsForLinks];
		
		// relayout / redraw
		[self setNeedsDisplay];
		
		// size might have changed
		[self sizeToFit];
	}
//	SYNCHRONIZE_END(self.layoutLock)
}

- (void)removeAttachmentCustomViewsNoLongerInLayoutFrame
{
	NSArray *attachmentsInFrame = [self.layoutFrame textAttachments];
	
	NSMutableArray *attachmentKeys = [[[customViewsForAttachmentsIndex allKeys] mutableCopy] autorelease];
	
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
