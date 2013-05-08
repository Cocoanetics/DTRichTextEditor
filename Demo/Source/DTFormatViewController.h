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
@property (assign, nonatomic, getter = isStrikethrough) BOOL strikethrough;

@end

@protocol DTFormatDelegate <NSObject>

- (void)formatDidSelectFont:(DTCoreTextFontDescriptor *)font;
- (void)formatDidToggleBold;
- (void)formatDidToggleItalic;
- (void)formatDidToggleUnderline;
- (void)formatDidToggleStrikethrough;
- (void)formatViewControllerUserDidFinish:(DTFormatViewController *)formatController;

@end

@protocol DTInternalFormatProtocol <NSObject>

@required
@property (strong, nonatomic) DTCoreTextFontDescriptor *fontDescriptor;
@property (assign, nonatomic, getter = isUnderlined) BOOL underline;
- (void)applyFont:(DTCoreTextFontDescriptor *)font;
- (void)applyFontSize:(CGFloat)pointSzie;
- (void)applyBold:(BOOL)active;
- (void)applyItalic:(BOOL)active;
- (void)applyUnderline:(BOOL)active;
- (void)applyStrikethrough:(BOOL)active;
@end