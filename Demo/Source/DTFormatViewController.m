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
@property (strong, readwrite) DTCoreTextFontDescriptor *currentFont;
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

- (void)applyFont:(DTCoreTextFontDescriptor *)font
{
    self.currentFont = font;
    self.currentFont.pointSize = self.fontDescriptor.pointSize;
    
    [self.formatDelegate formatDidSelectFont:self.currentFont];
}

- (void)setFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    _fontDescriptor = fontDescriptor;
    self.currentFont = self.fontDescriptor;
}

@end
