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
@property (nonatomic, strong) DPTableViewCellSegmentedControl *alignmentSegmentedControl;

@property (nonatomic, weak) DTFormatViewController<DTInternalFormatProtocol> *formatPicker;

- (void)_stepperValueChanged:(UIStepper *)stepper;

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
    
    DPTableViewCellSegmentedControlItem *boldItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_seg-BIU_bold_N.png"], [UIImage imageNamed:@"TSWP_seg-BIU_bold_S.png"] ]];
    DPTableViewCellSegmentedControlItem *italicItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_seg-BIU_italic_N.png"], [UIImage imageNamed:@"TSWP_seg-BIU_italic_S.png"] ]];
    DPTableViewCellSegmentedControlItem *underlineItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_seg-BIU_underline_N.png"], [UIImage imageNamed:@"TSWP_seg-BIU_underline_S.png"] ]];
    DPTableViewCellSegmentedControlItem *strikeItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_seg-BIU_strikethrough_N.png"], [UIImage imageNamed:@"TSWP_seg-BIU_strikethrough_S.png"] ]];
    
    self.styleSegmentedControl = [[DPTableViewCellSegmentedControl alloc] initWithItems:@[ boldItem, italicItem, underlineItem, strikeItem ]];
    [self.styleSegmentedControl addTarget:self action:@selector(_styleValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    DPTableViewCellSegmentedControlItem *leftItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_align-H_left_N.png"], [UIImage imageNamed:@"TSWP_align-H_left_S.png"] ]];
    DPTableViewCellSegmentedControlItem *centerItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_align-H_center_N.png"], [UIImage imageNamed:@"TSWP_align-H_center_S.png"] ]];
    DPTableViewCellSegmentedControlItem *rightItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_align-H_right_N.png"], [UIImage imageNamed:@"TSWP_align-H_right_S.png"] ]];
    DPTableViewCellSegmentedControlItem *justifyItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_align-H_justify_N.png"], [UIImage imageNamed:@"TSWP_align-H_justify_S.png"] ]];
    
    self.alignmentSegmentedControl = [[DPTableViewCellSegmentedControl alloc] initWithItems:@[ leftItem, centerItem, rightItem, justifyItem ]];
    self.alignmentSegmentedControl.allowMultipleSelection = NO;
    [self.alignmentSegmentedControl addTarget:self action:@selector(_alignmentValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)_styleValueChanged:(DPTableViewCellSegmentedControl *)control
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

- (void)_alignmentValueChanged:(DPTableViewCellSegmentedControl *)control
{
    switch(control.selectedIndex){
        case 0:
            [self.formatPicker applyTextAlignment:kCTLeftTextAlignment];
            break;
        case 1:
            [self.formatPicker applyTextAlignment:kCTCenterTextAlignment];
            break;
        case 2:
            [self.formatPicker applyTextAlignment:kCTRightTextAlignment];
            break;
        case 3:
            [self.formatPicker applyTextAlignment:kCTJustifiedTextAlignment];
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
    
    self.styleSegmentedControl.itemSelectedState = @[@(self.formatPicker.fontDescriptor.boldTrait),
                                                     @(self.formatPicker.fontDescriptor.italicTrait),
                                                     @(self.formatPicker.isUnderlined),
                                                     @(self.formatPicker.isStrikethrough)];
    
	NSInteger selectedIndex;
	CTTextAlignment alignment = self.formatPicker.textAlignment;
	switch (alignment) {
		case kCTNaturalTextAlignment:
		case kCTLeftTextAlignment:
			selectedIndex = 0;
			break;
		case kCTCenterTextAlignment:
			selectedIndex = 1;
			break;
		case kCTRightTextAlignment:
			selectedIndex = 2;
			break;
		case kCTJustifiedTextAlignment:
			selectedIndex = 3;
			break;
		default:
			selectedIndex = -1;
			break;
	}
	self.alignmentSegmentedControl.selectedIndex = selectedIndex;
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
    return section == 0 ? 2 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSInteger segmentedTag = 98;
    NSInteger alignementTag = 99;
    
    if( !cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    if( [cell.contentView viewWithTag:segmentedTag] && !(indexPath.section == 0 && indexPath.row == 1) )
    {
        UIView *targetView = [cell.contentView viewWithTag:segmentedTag];
        
        [targetView removeFromSuperview];
    }else if([cell.contentView viewWithTag:alignementTag] && !(indexPath.section == 1 && indexPath.row == 0)){
        UIView *targetView = [cell.contentView viewWithTag:alignementTag];
        
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
                
                self.styleSegmentedControl.tag = segmentedTag;
                self.styleSegmentedControl.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
                self.styleSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                self.styleSegmentedControl.cellPosition = DPTableViewCellSegmentedControlPositionBottom;
                [cell.contentView addSubview:self.styleSegmentedControl];
            }
            
        }
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row == 0){
            if ( ![cell.contentView viewWithTag:alignementTag] ){
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
                
                self.alignmentSegmentedControl.tag = alignementTag;
                self.alignmentSegmentedControl.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
                self.alignmentSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                self.alignmentSegmentedControl.cellPosition = DPTableViewCellSegmentedControlPositionTop;
                [cell.contentView addSubview:self.alignmentSegmentedControl];
            }
        }else{
            cell.textLabel.text = @"Font Family";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.formatPicker.fontDescriptor.fontFamily];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    NSAssert(cell, @"TableView Cell should never be nil");
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return @"Paragraph Style";
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 1)
        return;
    
    switch (indexPath.row)
    {
        case 1:
        {
            DTFormatFontFamilyTableViewController *fontFamilyChooserController = [[DTFormatFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped selectedFontFamily:self.formatPicker.fontDescriptor.fontFamily];
            [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
