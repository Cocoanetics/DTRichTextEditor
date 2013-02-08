//
//  TextView.h
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import <CoreText/CoreText.h>

@class DTAttributedTextContentView;
@class DTCoreTextLayoutFrame;
@class DTTextBlock;
@class DTCoreTextLayouter;
@class DTTextAttachment;

/** 
 notification that gets sent as soon as the receiver has done a layout pass
 */
extern NSString * const DTAttributedTextContentViewDidFinishLayoutNotification;

/**
 Protocol to provide custom views for elements in an DTAttributedTextContentView. Also the delegate gets notified once the text view has been drawn.
 */
@protocol DTAttributedTextContentViewDelegate <NSObject>

@optional

/**
 @name Notifications
 */


/**
 Called after a layout frame or a part of it is drawn. 
 
 @param attributedTextContentView The content view that drew a layout frame
 @param layoutFrame The layout frame that was drawn for
 @param context The graphics context that was drawn into
 */
- (void)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView didDrawLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame inContext:(CGContextRef)context;


/**
 Called before the text belonging to a text block is drawn.
 
 This gives the developer an opportunity to draw a custom background below a text block.
 
 @param attributedTextContentView The content view that drew a layout frame
 @param textBlock The text block
 @param rect The frame within the content view's coordinate system that will be drawn into
 @param context The graphics context that will be drawn into
 @param layoutFrame The layout frame that will be drawn for
 @param returns `YES` is the standard fill of the text block should be drawn, `NO` if it should not
 */
- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame; 

/**
 @name Providing Custom Views for Content
 */


/**
 Provide custom view for an attachment, e.g. an imageView for images
 
 @param attributedTextContentView The content view asking for a custom view
 @param attachment The <DTTextAttachment> that this view should represent
 @param frame The frame that the view should use to fit on top of the space reserved for the attachment
 @returns The view that should represent the given attachment
 */
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame;


/**
 Provide button to be placed over links, the identifier is used to link multiple parts of the same A tag

 @param attributedTextContentView The content view asking for a custom view
 @param url The `NSURL` of the hyperlink
 @param identifier An identifier that uniquely identifies the hyperlink within the document
 @param frame The frame that the view should use to fit on top of the space reserved for the attachment
 @returns The view that should represent the given hyperlink
 */
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame;


/** 
 Provide generic views for all attachments.
 
 This is only called if the more specific delegate methods are not implemented.
 
 @param attributedTextContentView The content view asking for a custom view
 @param string The attributed sub-string containing this element
 @param frame The frame that the view should use to fit on top of the space reserved for the attachment
 @returns The view that should represent the given hyperlink or text attachment
 @see attributedTextContentView:viewForAttachment:frame: and attributedTextContentView:viewForAttachment:frame:
 */
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame;

@end


enum {
    DTAttributedTextContentViewRelayoutNever            = 0,
	DTAttributedTextContentViewRelayoutOnWidthChanged   = 1 << 0,
	DTAttributedTextContentViewRelayoutOnHeightChanged  = 1 << 1,
};
typedef NSUInteger DTAttributedTextContentViewRelayoutMask;


@interface DTAttributedTextContentView : UIView
{
	NSAttributedString *_attributedString;
	DTCoreTextLayoutFrame *_layoutFrame;
	
	UIEdgeInsets _edgeInsets;
	
	NSMutableDictionary *customViewsForAttachmentsIndex;

	BOOL _flexibleHeight;
}

- (void)layoutSubviewsInRect:(CGRect)rect;
- (void)relayoutText;
- (void)removeAllCustomViews;
- (void)removeAllCustomViewsForLinks;

- (CGSize)attributedStringSizeThatFits:(CGFloat)width;
- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width; // obeys the edge insets

/**
 The size of contents of the receiver. This is possibly used by auto-layout, but also for example if you want to get the size of the receiver necessary for a scroll view
 
 This method is defined as of iOS 6, but to support earlier OS versions 
 */
- (CGSize)intrinsicContentSize;

// properties are overwritten with locking to avoid problem with async drawing
@property (atomic, strong) DTCoreTextLayouter *layouter;
@property (atomic, strong) DTCoreTextLayoutFrame *layoutFrame;

@property (nonatomic, strong) NSMutableSet *customViews;

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) BOOL shouldDrawImages;
@property (nonatomic) BOOL shouldDrawLinks;
@property (nonatomic) BOOL shouldLayoutCustomSubviews;
@property (nonatomic) CGPoint layoutOffset;
@property (nonatomic) CGSize backgroundOffset;

/**
 An integer bit mask that determines how the receiver relayouts its contents when its bounds change.
 
 When the view’s bounds change, that view automatically re-layouts its text according to the relayout mask. You specify the value of this mask by combining the constants described in DTAttributedTextContentViewRelayoutMask using the C bitwise OR operator. Combining these constants lets you specify which dimensions will cause a re-layout if modified. The default value of this property is DTAttributedTextContentViewRelayoutOnWidthChanged, which indicates that the text will be re-layouted if the width changes, but not if the height changes.
 */
@property (nonatomic) DTAttributedTextContentViewRelayoutMask relayoutMask;

@property (nonatomic, assign) IBOutlet id <DTAttributedTextContentViewDelegate> delegate;	// subtle simulator bug - use assign not __unsafe_unretained

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t layoutQueue;  // GCD objects use ARC
#else
@property (nonatomic, assign) dispatch_queue_t layoutQueue;  // GCD objects don't use ARC
#endif


@end


@interface DTAttributedTextContentView (Tiling)

+ (void)setLayerClass:(Class)layerClass;
+ (Class)layerClass;

@end

