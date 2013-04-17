//
//  DTRTEFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRTEFormatViewController.h"
#import "DTRichTextEditorFormatViewController.h"
#import "DTCoreTextFontDescriptor.h"

@interface DTRTEFormatViewController ()
@property (strong) DTCoreTextFontDescriptor *fontDescriptor;
@end

@implementation DTRTEFormatViewController

- (id)initWithFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    self = [super init];
    if(self)
    {
        self.fontDescriptor = fontDescriptor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    DTRichTextEditorFormatViewController *homeFormatController = [[DTRichTextEditorFormatViewController alloc] init];
    
    self.viewControllers = @[homeFormatController];
}

@end
