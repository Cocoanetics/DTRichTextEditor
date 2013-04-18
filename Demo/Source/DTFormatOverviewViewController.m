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
@property (nonatomic, weak) UILabel *sizeValueLabel;
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
    
    DTFormatViewController *formatPicker = (DTFormatViewController *)self.navigationController;

    
    UIStepper *fontStepper = [[UIStepper alloc] init];
    fontStepper.minimumValue = 9;
    fontStepper.maximumValue = 288;
    
    [fontStepper addTarget:self action:@selector(_stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSizeStepper = fontStepper;
}

- (void)_stepperValueChanged:(UIStepper *)stepper;
{    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyFontSize:stepper.value];
    
    self.sizeValueLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", stepper.value];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
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
        self.fontSizeStepper.value = formatPicker.currentFont.pointSize;
        cell.textLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", formatPicker.currentFont.pointSize ];
        self.sizeValueLabel = cell.textLabel;
        cell.accessoryView = self.fontSizeStepper;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f pt", formatPicker.currentFont.pointSize];
    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = @"Font";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", formatPicker.currentFont.fontFamily, formatPicker.currentFont.fontName ];
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
