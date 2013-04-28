//
//  DTRTEFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatViewController.h"
#import "DTFormatOverviewViewController.h"
#import "DTCoreTextFontDescriptor.h"

@interface DTFormatViewController ()<DTInternalFormatProtocol>
@property (strong, readwrite, nonatomic) DTCoreTextFontDescriptor *currentFont;
@end

@implementation DTFormatViewController

@synthesize fontDescriptor = _fontDescriptor;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
        
    DTFormatOverviewViewController *homeFormatController = [[DTFormatOverviewViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    self.viewControllers = @[homeFormatController];
}

- (void)setFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    _fontDescriptor = fontDescriptor;
    self.currentFont = self.fontDescriptor;
    
    if(self.viewControllers.count > 0){
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
        [homeFormatController.tableView reloadData];
    }
}

- (void)setUnderline:(BOOL)underline
{
    _underline = underline;
    
    if(self.viewControllers.count > 0){
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
        [homeFormatController.tableView reloadData];
    }
}

#pragma mark - DTInternalFormatProtocol methods
- (void)applyFont:(DTCoreTextFontDescriptor *)font
{
    self.currentFont = font;
    self.currentFont.pointSize = self.fontDescriptor.pointSize;
    
    [self.formatDelegate formatDidSelectFont:self.currentFont];
}

- (void)applyFontSize:(CGFloat)pointSzie
{
    self.currentFont.pointSize = pointSzie;
    [self.formatDelegate formatDidSelectFont:self.currentFont];
}

- (void)applyBold:(BOOL)active
{
    self.currentFont.boldTrait = active;
    [self.formatDelegate formatDidToggleBold];
}

- (void)applyItalic:(BOOL)active
{
    self.currentFont.italicTrait = active;
    [self.formatDelegate formatDidToggleItalic];
}

- (void)applyUnderline:(BOOL)active
{
    _underline = active;
    [self.formatDelegate formatDidToggleUnderline];
}

@end
