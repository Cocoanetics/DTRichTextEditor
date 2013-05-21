//
//  DTRTEFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatViewController.h"
#import "DTFormatOverviewViewController.h"
#import "DTFormatFontFamilyTableViewController.h"
#import "DTCoreTextFontDescriptor.h"

@interface DTFormatViewController ()<DTInternalFormatProtocol>

@end

@implementation DTFormatViewController

@synthesize fontDescriptor = _fontDescriptor;

- (id)init
{
    self = [super init];
    if(self){
        self.textAlignment = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    DTFormatOverviewViewController *homeFormatController = [[DTFormatOverviewViewController alloc] init];
    
    self.viewControllers = @[homeFormatController];
}

- (CGSize)contentSizeForViewInPopover
{
    return self.topViewController.contentSizeForViewInPopover;
}

- (void)setFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    if(fontDescriptor == _fontDescriptor)
        return;

    _fontDescriptor = fontDescriptor;
    
    if(self.viewControllers.count > 0){
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
        [homeFormatController.visibleTableViewController.tableView reloadData];
        
        if ([self.topViewController isKindOfClass:[DTFormatFontFamilyTableViewController class]])
        {
            DTFormatFontFamilyTableViewController *fontFamilyController = (DTFormatFontFamilyTableViewController *)self.topViewController;
            [fontFamilyController setSelectedFontFamily:fontDescriptor.fontFamily];
        }
    }
}

- (void)setUnderline:(BOOL)underline
{
    _underline = underline;
    
    if(self.viewControllers.count > 0){
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
        [homeFormatController.visibleTableViewController.tableView reloadData];
    }
}

#pragma mark - DTInternalFormatProtocol methods
- (void)applyFont:(DTCoreTextFontDescriptor *)font
{
    CGFloat pointSize = self.fontDescriptor.pointSize;
    
    self.fontDescriptor = font;
    self.fontDescriptor.pointSize = pointSize;
    
    [self.formatDelegate formatDidSelectFont:self.fontDescriptor];
}

- (void)applyFontSize:(CGFloat)pointSzie
{
    self.fontDescriptor.pointSize = pointSzie;
    [self.formatDelegate formatDidSelectFont:self.fontDescriptor];
}

- (void)applyBold:(BOOL)active
{
    self.fontDescriptor.boldTrait = active;
    [self.formatDelegate formatDidToggleBold];
}

- (void)applyItalic:(BOOL)active
{
    self.fontDescriptor.italicTrait = active;
    [self.formatDelegate formatDidToggleItalic];
}

- (void)applyUnderline:(BOOL)active
{
    _underline = active;
    [self.formatDelegate formatDidToggleUnderline];
}

- (void)applyStrikethrough:(BOOL)active
{
    _strikethrough = active;
    [self.formatDelegate formatDidToggleStrikethrough];
}

- (void)applyTextAlignment:(CTTextAlignment)alignment
{
    [self.formatDelegate formatDidChangeTextAlignment:alignment];
}

#pragma mark - Event bubbling

- (void)userPressedDone:(id)sender
{
    [self.formatDelegate formatViewControllerUserDidFinish:self];
}

@end
