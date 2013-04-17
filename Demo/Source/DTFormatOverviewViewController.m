//
//  DTRichTextEditorFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatOverviewViewController.h"
#import "DTCoreTextFontDescriptor.h"
#import "DTFormatViewController.h"

#import "DTFormatFontFamilyTableViewController.h"
#import "DTFormatViewController.h"

@interface DTFormatOverviewViewController()
@property (nonatomic, strong) UIStepper *fontSizeStepper;
@end

@implementation DTFormatOverviewViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Format";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    DTFormatViewController *formatPicker = (DTFormatViewController *)self.navigationController;

    
    UIStepper *fontStepper = [[UIStepper alloc] init];
    fontStepper.minimumValue = 9;
    fontStepper.maximumValue =  288;
    fontStepper.value = formatPicker.currentFont.pointSize;
    
    self.fontSizeStepper = fontStepper;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    - (void)updateFontInRange:(UITextRange *)range withFontFamilyName:(NSString *)fontFamilyName pointSize:(CGFloat)pointSize;
//    - (DTCoreTextFontDescriptor *)fontDescriptorForRange:(UITextRange *)range;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    DTFormatViewController *formatPicker = (DTFormatViewController *)self.navigationController;

    if(indexPath.section == 0)
    {
        cell.textLabel.text = @"Size";
        cell.accessoryView = self.fontSizeStepper;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f pt", formatPicker.currentFont.pointSize];
    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = @"Font";
        cell.detailTextLabel.text = formatPicker.currentFont.fontFamily;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return;
    
    DTFormatFontFamilyTableViewController *fontFamilyChooserController = [[DTFormatFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
}

@end
