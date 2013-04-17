//
//  DTRTEFormatViewController.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCoreTextFontDescriptor;
@protocol DTRTEFormatDelegate;

@interface DTRTEFormatViewController : UINavigationController

@property (assign) id<DTRTEFormatDelegate> formatDelegate;

- (id)initWithFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor;

- (void)updateFont:(UIFont *)font;

@end

@protocol DTRTEFormatDelegate <NSObject>

- (void)formatDidSelectFont:(UIFont *)font;

@end