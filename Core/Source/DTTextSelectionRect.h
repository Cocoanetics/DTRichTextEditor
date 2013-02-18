//
//  DTTextSelectionRect.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 9/11/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

@class DTTextSelectionRect;

/**
 Protocol for a objects representing part of a text selection.
 */
@protocol DTTextSelectionRect <NSObject>

/**
 The frame rectangle of the selection
 */
@property (nonatomic, assign) CGRect rect;

/**
 The writing direction of the selection
 @note This is not implemented
 */
@property (nonatomic, assign) UITextWritingDirection writingDirection;

/**
 Whether the receiver contains the beginning of the selection
 
 Returns `YES` if the rect contains the start of the selection.
 */
@property (nonatomic, assign) BOOL containsStart;

/**
 Whether the receiver contains the end of the selection
 
 Returns `YES` if the rect contains the end of the selection.
 */
@property (nonatomic, assign) BOOL containsEnd;

/**
 Whether the receiver contains vertical text.
 
 Returns `YES` if the rect is for vertically oriented text.
 @note This is not implemented
 */
@property (nonatomic, assign) BOOL isVertical;

@end


// on iOS 6 there is a new UITextSelectionRect class we want to be a subclass of
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1

/**
 The concrete class to represent a text selection rectangle. The receiver conforms to the DTTextSelectionRect protocol.
 
 As of iOS6 there is an abstract `UITextSelectionRect` that will be used if the deployment target is iOS 6 or higher. In these cases text selection will be represented by DTTextSelectionRectDerived instances otherwise DTTextSelectionRect will be used.
 */
@interface DTTextSelectionRectDerived : UITextSelectionRect <DTTextSelectionRect>
@end
#endif

/**
 The concrete class to represent a text selection rectangle. The receiver conforms to the DTTextSelectionRect protocol.
 
 As of iOS6 there is an abstract `UITextSelectionRect` that will be used if the deployment target is iOS 6 or higher. In these cases text selection will be represented by DTTextSelectionRectDerived instances otherwise DTTextSelectionRect will be used.
 */

@interface DTTextSelectionRect : NSObject <DTTextSelectionRect>

/**
 Convenience method for creating a selection rect from a frame rect.
 @param rect The frame rectangle
 @returns An initialized selection rectangle.
 */
+ (id <DTTextSelectionRect>)textSelectionRectWithRect:(CGRect)rect;

@end

