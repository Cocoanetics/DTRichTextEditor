//
//  DTFormatListViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 08/05/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatListViewController.h"
#import "DPTableViewCellSegmentedControl.h"
#import "DTFormatViewController.h"

@interface DTFormatListViewController ()
@property (nonatomic, weak) DTFormatViewController<DTInternalFormatProtocol> *formatPicker;
@property (nonatomic, strong) DPTableViewCellSegmentedControl *tabulationControl;
@end

@implementation DTFormatListViewController

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320.0, 400.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.formatPicker = (DTFormatViewController<DTInternalFormatProtocol> *)self.navigationController;
    
    DPTableViewCellSegmentedControlItem *leftItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_ListOutdent_N.png"], [UIImage imageNamed:@"TSWP_ListOutdent_S.png"] ]];
    DPTableViewCellSegmentedControlItem *rightItem = [DPTableViewCellSegmentedControlItem itemWithImages:@[ [UIImage imageNamed:@"TSWP_ListIndent_N.png"], [UIImage imageNamed:@"TSWP_ListIndent_S.png"] ]];
    
    self.tabulationControl = [[DPTableViewCellSegmentedControl alloc] initWithItems:@[ leftItem, rightItem ]];
    self.tabulationControl.allowMultipleSelection = NO;
    self.tabulationControl.allowSelectedState = NO;
    [self.tabulationControl addTarget:self action:@selector(_tabulationValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)_tabulationValueChanged:(DPTableViewCellSegmentedControl *)control
{
    switch(control.selectedIndex){
        case 0:
            [self.formatPicker decreaseTabulation];
            break;
        case 1:
            [self.formatPicker increaseTabulation];
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == 0 ? 1 : 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *normalCell = @"Cell";
    static NSString *segmentedCell = @"SegmentedCell";
    
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:segmentedCell];
        if( !cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:segmentedCell];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:normalCell];
        if( !cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:normalCell];
        }
    }

    NSInteger tabulationTag = 99;
    
    if (indexPath.section == 0)
	{
        if (![cell.contentView viewWithTag:tabulationTag])
		{
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            
            self.tabulationControl.tag = tabulationTag;
            self.tabulationControl.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
            self.tabulationControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.tabulationControl.cellPosition = DPTableViewCellSegmentedControlPositionSingle;
            [cell.contentView addSubview:self.tabulationControl];
        }
    }
	else if(indexPath.section == 1)
	{
        if( [cell.contentView viewWithTag:tabulationTag] )
		{
            UIView *targetView = [cell.contentView viewWithTag:tabulationTag];
            
            [targetView removeFromSuperview];
        }
        
        switch (indexPath.row)
		{
            case 0:
                cell.textLabel.text = @"None";
                cell.accessoryType = self.formatPicker.listType == (DTCSSListStyleTypeInherit | DTCSSListStyleTypeInherit) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.textLabel.text = @"• Bullet";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeDisc ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.textLabel.text = @"1. Numbered";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeDecimal ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.textLabel.text = @"\u25AA Square";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeSquare ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 4:
                cell.textLabel.text = @"a. Lowercase Latin";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeLowerLatin ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 5:
                cell.textLabel.text = @"A. Uppercase Latin";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeUpperLatin ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 6:
                cell.textLabel.text = @"_ Underscore";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypeUnderscore ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
            case 7:
                cell.textLabel.text = @"+ Plus";
                cell.accessoryType = self.formatPicker.listType == DTCSSListStyleTypePlus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
                
            default:
                break;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
	{
        case 1:
            return @"List Type";
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
	{
        return;
	}
    
    switch (indexPath.row)
	{
        case 0:
            [self.formatPicker toggleListType:DTCSSListStyleTypeNone];
            break;
        case 1:
            [self.formatPicker toggleListType:DTCSSListStyleTypeDisc];
            break;
        case 2:
            [self.formatPicker toggleListType:DTCSSListStyleTypeDecimal];
            break;
        case 3:
            [self.formatPicker toggleListType:DTCSSListStyleTypeSquare];
            break;
        case 4:
            [self.formatPicker toggleListType:DTCSSListStyleTypeLowerLatin];
            break;
        case 5:
            [self.formatPicker toggleListType:DTCSSListStyleTypeUpperLatin];
            break;
        case 6:
            [self.formatPicker toggleListType:DTCSSListStyleTypeUnderscore];
            break;
        case 7:
            [self.formatPicker toggleListType:DTCSSListStyleTypePlus];
            break;
        default:
            break;
    }
    
    [[tableView visibleCells] makeObjectsPerformSelector:@selector(setAccessoryType:) withObject:@(UITableViewCellAccessoryNone)];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
