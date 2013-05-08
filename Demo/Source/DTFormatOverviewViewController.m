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

@property (nonatomic, weak) DTFormatViewController<DTInternalFormatProtocol> *formatPicker;
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
    
    NSAssert([self.navigationController isKindOfClass:[DTFormatViewController class]], @"Must use inside a DTFormatViewController");
    
    self.formatPicker = (DTFormatViewController<DTInternalFormatProtocol> *)self.navigationController;
    
    UIStepper *fontStepper = [[UIStepper alloc] init];
    fontStepper.minimumValue = 9;
    fontStepper.maximumValue = 288;
    
    [fontStepper addTarget:self action:@selector(_stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSizeStepper = fontStepper;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // on the phone this controller will be presented modally
        // we need a control to dismiss ourselves
        
        // add a bar button item to close
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"\u25BC"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:nil
                                                                     action:@selector(userPressedDone:)];
        self.navigationItem.rightBarButtonItem = closeItem;
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
    self.formatPicker.currentFont.boldTrait = !self.formatPicker.currentFont.boldTrait;
    
    [self.formatPicker applyBold:self.formatPicker.currentFont.boldTrait];
}

- (void)_editItalicTrait
{    
    self.formatPicker.currentFont.italicTrait = !self.formatPicker.currentFont.italicTrait;
    
    [self.formatPicker applyItalic:self.formatPicker.currentFont.italicTrait];
}

- (void)_editUnderlineTrait
{    
    [self.formatPicker applyUnderline:YES];
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
    return section == 0 ? 1 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    if(indexPath.section == 0)
    {
        self.fontSizeStepper.value = self.formatPicker.currentFont.pointSize;
        cell.textLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", self.formatPicker.currentFont.pointSize ];
        self.sizeValueLabel = cell.textLabel;
        cell.accessoryView = self.fontSizeStepper;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 1)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if(indexPath.row == 0){
            cell.textLabel.text = @"Font Family";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.formatPicker.currentFont.fontFamily];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            // bold, italic, underline
            
            switch (indexPath.row) {
                case 1:
                    //bold
                    cell.textLabel.text = @"Bold";
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
                    cell.accessoryType = self.formatPicker.currentFont.boldTrait ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 2:
                    //italic
                    cell.textLabel.text = @"Italic";
                    cell.textLabel.font = [UIFont italicSystemFontOfSize:18.0];
                    cell.accessoryType = self.formatPicker.currentFont.italicTrait ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 3:
                    //underline
                {
                    NSMutableAttributedString *underlineString = [[NSMutableAttributedString alloc] initWithString:@"Underline"];
                    [underlineString addAttribute:NSUnderlineStyleAttributeName
                                            value:@(YES)
                                            range:(NSRange){0,[underlineString length]}];
                    cell.textLabel.attributedText = underlineString;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
                    cell.accessoryType = self.formatPicker.isUnderlined ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return;
    
    switch (indexPath.row) {
        case 0:
        {
            DTFormatFontFamilyTableViewController *fontFamilyChooserController = [[DTFormatFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped selectedFontFamily:self.formatPicker.currentFont.fontFamily];
            [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
        }
            break;
        case 1:
        {
            [self _editBoldTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
        }
            break;
        case 2:
        {
            [self _editItalicTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
        }
            break;
        case 3:
        {
            [self _editUnderlineTrait];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark];
        }
            break;
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
