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

@property (weak, nonatomic) id<DTFormatDelegate> formatDelegate;
@property (strong, nonatomic) DTCoreTextFontDescriptor *fontDescriptor;
@property (assign, nonatomic, getter = isUnderlined) BOOL underline;
@property (strong, readonly, nonatomic) DTCoreTextFontDescriptor *currentFont;

@end

@protocol DTFormatDelegate <NSObject>

- (void)formatDidSelectFont:(DTCoreTextFontDescriptor *)font;
- (void)formatDidToggleBold;
- (void)formatDidToggleItalic;
- (void)formatDidToggleUnderline;

@end

@protocol DTInternalFormatProtocol <NSObject>

@required
@property (strong, readonly) DTCoreTextFontDescriptor *currentFont;
@property (assign, nonatomic, getter = isUnderlined) BOOL underline;
- (void)applyFont:(DTCoreTextFontDescriptor *)font;
- (void)applyFontSize:(CGFloat)pointSzie;
- (void)applyBold:(BOOL)active;
- (void)applyItalic:(BOOL)active;
- (void)applyUnderline:(BOOL)active;
@end