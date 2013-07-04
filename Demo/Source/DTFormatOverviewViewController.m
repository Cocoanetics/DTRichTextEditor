//
//  DTRichTextEditorFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatOverviewViewController.h"
#import "DTFormatViewController.h"

#import "DTFormatStyleViewController.h"
#import "DTFormatListViewController.h"
#import "DTFormatOtherViewController.h"

@interface DTFormatOverviewViewController()

@property (nonatomic, strong) DTFormatStyleViewController *styleTableViewController;
@property (nonatomic, strong) DTFormatListViewController *listTableViewController;
@property (nonatomic, strong) DTFormatOtherViewController *otherTableViewController;
@property (nonatomic, strong) UIImagePickerController *mediaController;
@property (nonatomic, weak, readwrite) UIViewController *visibleTableViewController;

@end

@implementation DTFormatOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert([self.navigationController isKindOfClass:[DTFormatViewController class]], @"Must use inside a DTFormatViewController");
    
    NSArray *optionsArray = @[ @"Style", @"List", @"Media", @"Other" ];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // on the phone this controller will be presented modally
        // we need a control to dismiss ourselves
        
        // add a bar button item to close
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"\u25BC"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:nil
                                                                     action:@selector(userPressedDone:)];
        self.navigationItem.rightBarButtonItem = closeItem;
        
        optionsArray = @[optionsArray[0], optionsArray[1], optionsArray[3] ];
    }
    
    UISegmentedControl *formatTypeChooser = [[UISegmentedControl alloc] initWithItems:optionsArray];
    formatTypeChooser.segmentedControlStyle = UISegmentedControlStyleBar;
    
    formatTypeChooser.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(formatTypeChooser.bounds));
    formatTypeChooser.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    formatTypeChooser.selectedSegmentIndex = 0;
    [formatTypeChooser addTarget:self action:@selector(_formatTypeChooserValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = formatTypeChooser;

    [self _formatTypeChooserValueChanged:nil];
}

#pragma mark - Segmented Control Methods
- (void)_formatTypeChooserValueChanged:(UISegmentedControl *)control
{
    UIViewController *newViewController = nil;
    
    NSUInteger selectedIndex = control ? control.selectedSegmentIndex : 0;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && selectedIndex == 2)
        selectedIndex = 3;
    
    switch (selectedIndex) {
        case 0:
        {
            // Style
            if( !self.styleTableViewController ){
                self.styleTableViewController = [[DTFormatStyleViewController alloc] initWithStyle:UITableViewStyleGrouped];
            }
            
            newViewController = self.styleTableViewController;
        }
            break;
        case 1:
        {
            // List
            if( !self.listTableViewController ){
                self.listTableViewController = [[DTFormatListViewController alloc] initWithStyle:UITableViewStyleGrouped];
            }
            
            newViewController = self.listTableViewController;
        }
            break;
        case 2:
        {
            // Media
            if( !self.mediaController ){
                self.mediaController = [[UIImagePickerController alloc] init];
                self.mediaController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                self.mediaController.delegate = (DTFormatViewController<DTInternalFormatProtocol>*)self.navigationController;
            }
            
            newViewController = self.mediaController;
        }
            break;
        case 3:
            if( !self.otherTableViewController ){
                self.otherTableViewController = [[DTFormatOtherViewController alloc] initWithStyle:UITableViewStyleGrouped];
            }
            
            newViewController = self.otherTableViewController;

            break;
        default:
            break;
    }
    
    if (!newViewController)
        return;
    
    // remove old one
    [self.visibleTableViewController.view removeFromSuperview];
    [self.visibleTableViewController willMoveToParentViewController:nil];
    [self.visibleTableViewController removeFromParentViewController];

    // change the controller
    self.visibleTableViewController = newViewController;
        
    // add new one
    [self addChildViewController:self.visibleTableViewController];
    self.visibleTableViewController.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.visibleTableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.visibleTableViewController.view];
    [self.visibleTableViewController didMoveToParentViewController:self];
    
    self.contentSizeForViewInPopover = self.visibleTableViewController.contentSizeForViewInPopover;
}


@end
