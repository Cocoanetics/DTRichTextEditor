//
//  DTRTEFormatViewController.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCoreTextFontDescriptor;
@protocol DTFormatDelegate;

@interface DTFormatViewController : UINavigationController

@property (weak) id<DTFormatDelegate> formatDelegate;
@property (strong, nonatomic) DTCoreTextFontDescriptor *fontDescriptor;
@property (strong, readonly) DTCoreTextFontDescriptor *currentFont;

@end

@protocol DTFormatDelegate <NSObject>

- (void)formatDidSelectFont:(DTCoreTextFontDescriptor *)font;

@end

@protocol DTInternalFormatProtocol <NSObject>

@required
@property (strong, readonly) DTCoreTextFontDescriptor *currentFont;
- (void)applyFont:(DTCoreTextFontDescriptor *)font;
- (void)applyFontSize:(CGFloat)pointSzie;

@end