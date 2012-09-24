//
//  DTTextSelectionRect.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 9/11/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTTextSelectionRect;

@protocol DTTextSelectionRect <NSObject>

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) UITextWritingDirection writingDirection;
@property (nonatomic, assign) BOOL containsStart; // Returns YES if the rect contains the start of the selection.
@property (nonatomic, assign) BOOL containsEnd; // Returns YES if the rect contains the end of the selection.
@property (nonatomic, assign) BOOL isVertical; // Returns YES if the rect is for vertically oriented text.

@end


// on iOS 6 there is a new UITextSelectionRect class we want to be a subclass of
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
@interface DTTextSelectionRectDerived : UITextSelectionRect <DTTextSelectionRect>
@end
#endif


@interface DTTextSelectionRect : NSObject <DTTextSelectionRect>

+ (id <DTTextSelectionRect>)textSelectionRectWithRect:(CGRect)rect;

@end

