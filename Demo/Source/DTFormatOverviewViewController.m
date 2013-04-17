//
//  DTRichTextEditorFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorFormatViewController.h"
#import "DTCoreTextFontDescriptor.h"
#import "DTRTEFormatViewController.h"

#import "DTRichTextEditorFontFamilyTableViewController.h"

@implementation DTRichTextEditorFormatViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    - (void)updateFontInRange:(UITextRange *)range withFontFamilyName:(NSString *)fontFamilyName pointSize:(CGFloat)pointSize;
//    - (DTCoreTextFontDescriptor *)fontDescriptorForRange:(UITextRange *)range;
    
    
    
    UITextRange *range = self.richTextViewController.richEditor.selectedTextRange;
    self.fontDescriptor = [self.richTextViewController.richEditor fontDescriptorForRange:range];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    
    cell.textLabel.text = self.fontDescriptor.fontName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTRichTextEditorFontFamilyTableViewController *fontFamilyChooserController = [[DTRichTextEditorFontFamilyTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:fontFamilyChooserController animated:YES];
}

@end
