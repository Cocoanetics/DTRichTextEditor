//
//  DTFormatStyleViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 08/05/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatStyleViewController.h"

#import "DTCoreTextFontDescriptor.h"
#import "DTFormatViewController.h"

#import "DTFormatFontFamilyTableViewController.h"
#import "DTFormatViewController.h"

#import "DTAttributedTextCell.h"
#import "DPTableViewCellSegmentedControl.h"

@interface DTFormatStyleViewController ()

@property (nonatomic, strong) UIStepper *fontSizeStepper;
@property (nonatomic, weak) UILabel *sizeValueLabel;

@property (nonatomic, strong) DPTableViewCellSegmentedControl *styleSegmentedControl;

@property (nonatomic, weak) DTFormatViewController<DTInternalFormatProtocol> *formatPicker;

@end

@implementation DTFormatStyleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.formatPicker = (DTFormatViewController<DTInternalFormatProtocol> *)self.navigationController;
    
    UIStepper *fontStepper = [[UIStepper alloc] init];
    fontStepper.minimumValue = 9;
    fontStepper.maximumValue = 288;
    
    [fontStepper addTarget:self action:@selector(_stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSizeStepper = fontStepper;
    
    self.styleSegmentedControl = [[DPTableViewCellSegmentedControl alloc] initWithItems:@[ @"B", @"I", @"U", @"S" ]];
    self.styleSegmentedControl.itemSelectedState = @[@(self.formatPicker.fontDescriptor.boldTrait), @(self.formatPicker.fontDescriptor.italicTrait), @(NO), @(NO)];
    [self.styleSegmentedControl addTarget:self action:@selector(styleValueChanged:) forControlEvents:UIControlEventValueChanged];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.separatorColor = [UIColor redColor];
    
//    [self.tableView setSeparatorColor:[UIColor clearColor]];
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

}

- (void)styleValueChanged:(DPTableViewCellSegmentedControl *)control
{
    switch(control.selectedIndex){
        case 0:
            [self _editBoldTrait];
            break;
        case 1:
            [self _editItalicTrait];
            break;
        case 2:
            [self _editUnderlineTrait];
            break;
        case 3:
            [self _editStrikethroughTrait];
            break;
    }
}

- (CGSize)contentSizeForViewInPopover {
    // Currently no way to obtain the width dynamically before viewWillAppear.
    CGFloat width = 320.0;
    
    CGFloat totalHeight = 0.0;
    
    //Need to total each section
    for (int i = 0; i < [self.tableView numberOfSections]; i++)
    {
        CGRect sectionRect = [self.tableView rectForSection:i];
        totalHeight += sectionRect.size.height;
    }
    
    return (CGSize){width, totalHeight + 44.0};
}

- (void)_stepperValueChanged:(UIStepper *)stepper;
{
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyFontSize:stepper.value];
    
    self.sizeValueLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", stepper.value];
}

- (void)_editBoldTrait
{
    self.formatPicker.fontDescriptor.boldTrait = !self.formatPicker.fontDescriptor.boldTrait;
    
    [self.formatPicker applyBold:self.formatPicker.fontDescriptor.boldTrait];
}

- (void)_editItalicTrait
{
    self.formatPicker.fontDescriptor.italicTrait = !self.formatPicker.fontDescriptor.italicTrait;
    
    [self.formatPicker applyItalic:self.formatPicker.fontDescriptor.italicTrait];
}

- (void)_editUnderlineTrait
{
    [self.formatPicker applyUnderline:YES];
}

- (void)_editStrikethroughTrait
{
    [self.formatPicker applyStrikethrough:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.styleSegmentedControl.itemSelectedState = @[@(self.formatPicker.fontDescriptor.boldTrait), @(self.formatPicker.fontDescriptor.italicTrait), @(NO), @(NO)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    return section == 0 ? 2 : 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSInteger segmentedTag = 99;
    
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0))
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    else
    {
        cell = [[DTAttributedTextCell alloc] initWithReuseIdentifier:nil];
        [[(DTAttributedTextCell *)cell attributedTextContextView] setEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    
    if( [cell.contentView viewWithTag:segmentedTag] && !(indexPath.section == 0 && indexPath.row == 1) )
    {
        UIView *targetView = [cell.contentView viewWithTag:segmentedTag];
        
        [targetView removeFromSuperview];
    }
        
    if (indexPath.section == 0)
    {
        if(indexPath.row == 0){
            self.fontSizeStepper.value = self.formatPicker.fontDescriptor.pointSize;
            cell.textLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", self.formatPicker.fontDescriptor.pointSize ];
            self.sizeValueLabel = cell.textLabel;
            cell.accessoryView = self.fontSizeStepper;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else if (indexPath.row == 1){
            if ( ![cell.contentView viewWithTag:segmentedTag] ){
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                
                self.styleSegmentedControl.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
                self.styleSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                self.styleSegmentedControl.cellPosition = DPTableViewCellSegmentedControlPositionBottom;
                [cell.contentView addSubview:self.styleSegmentedControl];
            }

        }
    }
    else if (indexPath.section == 1)
    {
        DTAttributedTextCell *attributedCell = (DTAttributedTextCell *)cell;
        
        if(indexPath.row == 0)
        {
            cell.textLabel.text = @"Font Family";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.formatPicker.fontDescriptor.fontFamily];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            switch (indexPath.row)
            {
                case 1: //bold
                {
                    cell.accessoryType = self.formatPicker.fontDescriptor.boldTrait ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    [attributedCell setHTMLString:@"<b style=\"font-size:18px;font-family:\'Helvetica Neue\';\">Bold</b>"];
                    break;
                }
                    
                case 2: //italic
                {
                    cell.accessoryType = self.formatPicker.fontDescriptor.italicTrait ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    [attributedCell setHTMLString:@"<em style=\"font-size:18px;font-family:\'Helvetica Neue\';\">Italic</em>"];
                    break;
                }
                    
                case 3: //underline
                {
                    cell.accessoryType = self.formatPicker.isUnderlined ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    [attributedCell setHTMLString:@"<u style=\"font-size:18px;font-family:\'Helvetica Neue\';\">Underlined</u>"];
                    break;
                }
                    
                case 4: //strikethrough
                {
                    cell.accessoryType = self.formatPicker.isUnderlined ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    [attributedCell setHTMLString:@"<del style=\"font-size:18px;font-family:\'Helvetica Neue\';\">Strikethrough</del>"];
                    break;
                }
            }
        }
    }
    
    NSAssert(cell, @"TableView Cell should never be nil");
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!indexPath.section)
    {
        return;
    }
    
    switch (indexPath.row)
    {
        case 0:
        {
            DTFormatFontFamilyTableViewController *fontFamilyChooserController = [[DTFormatFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped selectedFontFamily:self.formatPicker.fontDescriptor.fontFamily];
            [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
            break;
        }
            
        case 1:
        {
            [self _editBoldTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
            break;
        }
            
        case 2:
        {
            [self _editItalicTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
            break;
        }
            
        case 3:
        {
            [self _editUnderlineTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
            break;
        }
            
        case 4:
        {
            [self _editStrikethroughTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
            break;
        }
            
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
