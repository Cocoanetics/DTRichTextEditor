//
//  DTTextSelectionRect.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 9/11/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
#define SELECTION_SUPER_CLASS UITextSelectionRect
#else
#define SELECTION_SUPER_CLASS NSObject
#endif

@interface DTTextSelectionRect : SELECTION_SUPER_CLASS

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) UITextWritingDirection writingDirection;
@property (nonatomic, assign) BOOL containsStart; // Returns YES if the rect contains the start of the selection.
@property (nonatomic, assign) BOOL containsEnd; // Returns YES if the rect contains the end of the selection.
@property (nonatomic, assign) BOOL isVertical; // Returns YES if the rect is for vertically oriented text.

+ (DTTextSelectionRect *)textSelectionRectWithRect:(CGRect)rect;

@end
