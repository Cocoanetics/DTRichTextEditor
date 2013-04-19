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
@property (nonatomic, strong) UIButton *boldTraitButton;
@property (nonatomic, strong) UIButton *italicTraitButton;
@property (nonatomic, strong) UIButton *underlineTraitButton;
@property (nonatomic, strong) UIView *buttonsView;
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
        
    UIStepper *fontStepper = [[UIStepper alloc] init];
    fontStepper.minimumValue = 9;
    fontStepper.maximumValue = 288;
    
    [fontStepper addTarget:self action:@selector(_stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSizeStepper = fontStepper;
    
    CGFloat buttonWidth = 50.0;
    
    UIButton *boldButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    boldButton.frame = CGRectMake(0.0, 0.0, buttonWidth, 37.0);
    boldButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [boldButton setTitle:@"B" forState:UIControlStateNormal];
    [boldButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [boldButton addTarget:self action:@selector(_editBoldTrait:) forControlEvents:UIControlEventTouchUpInside];
    self.boldTraitButton = boldButton;

    UIButton *italicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    italicButton.frame = CGRectMake(buttonWidth * 1, 0.0, buttonWidth, 37.0);
    italicButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [italicButton setTitle:@"I" forState:UIControlStateNormal];
    [italicButton.titleLabel setFont:[UIFont italicSystemFontOfSize:18.0]];
    [italicButton addTarget:self action:@selector(_editItalicTrait:) forControlEvents:UIControlEventTouchUpInside];
    self.italicTraitButton = italicButton;

    UIButton *underlineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    underlineButton.frame = CGRectMake(buttonWidth * 2, 0.0, buttonWidth, 37.0);
    underlineButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    NSString *underLineText = @"U";
    if (underLineText != nil && ![underLineText isEqualToString:@""]) {
        NSMutableAttributedString *temString=[[NSMutableAttributedString alloc]initWithString:underLineText];
        [temString addAttribute:NSUnderlineStyleAttributeName
                          value:@(YES)
                          range:(NSRange){0,[temString length]}];
        [underlineButton setAttributedTitle:temString forState:UIControlStateNormal];
    }
    [underlineButton addTarget:self action:@selector(_editUnderlineTrait:) forControlEvents:UIControlEventTouchUpInside];

    self.underlineTraitButton = underlineButton;
    
    UIView *buttonsCellView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 37.0)];
    
    [buttonsCellView addSubview:self.boldTraitButton];
    [buttonsCellView addSubview:self.italicTraitButton];
    [buttonsCellView addSubview:self.underlineTraitButton];
    
    self.buttonsView = buttonsCellView;
}

- (void)_stepperValueChanged:(UIStepper *)stepper;
{    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyFontSize:stepper.value];
    
    self.sizeValueLabel.text = [NSString stringWithFormat:@"Size (%.0f pt)", stepper.value];
}

- (void)_editBoldTrait:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyBold:sender.selected];
}

- (void)_editItalicTrait:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyItalic:sender.selected];
}

- (void)_editUnderlineTrait:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    
    [formatController applyUnderline:sender.selected];
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
    return section == 0 ? 1 : 2;
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
        if(indexPath.row == 0){
            cell.textLabel.text = @"Font";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", formatPicker.currentFont.fontFamily];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }else{
            if(![cell.contentView.subviews containsObject:self.buttonsView])
            {
                [cell.contentView addSubview:self.buttonsView];
                self.buttonsView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds), CGRectGetHeight(cell.contentView.bounds));
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
    
    DTFormatFontFamilyTableViewController *fontFamilyChooserController = [[DTFormatFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
}

@end
