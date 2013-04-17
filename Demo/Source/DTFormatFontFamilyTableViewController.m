//
//  DTRichTextEditorFontFamilyTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorFontFamilyTableViewController.h"

#import "DTRichTextEditorFontTableViewController.h"

@interface DTRichTextEditorFontFamilyTableViewController ()
@property (nonatomic, assign) NSInteger selectedRow;
@end

@implementation DTRichTextEditorFontFamilyTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.selectedRow = -1;
    }
    return self;
}

+ (NSArray *)getFontFamilies
{
    static NSArray *fontArray = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        fontArray = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    });
    return fontArray;
}

+ (NSArray *)getFontsForFamily:(NSString *)fontFamily __attribute__((const))
{
    NSArray *fontNames = [UIFont fontNamesForFamilyName:fontFamily];
    return fontNames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self class] getFontFamilies] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    // Configure the cell...
    
    NSString *fontFamily = [[[self class] getFontFamilies] objectAtIndex:indexPath.row];
        
    cell.textLabel.text = fontFamily;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectFontForIndexPath:indexPath];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DTRichTextEditorFontTableViewController *fontController = [[DTRichTextEditorFontTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    fontController.fontFamilyName = [[[self class] getFontFamilies] objectAtIndex:indexPath.row];
    fontController.richTextViewController = self.richTextViewController;
    
    [self.navigationController pushViewController:fontController animated:YES];
        
    [self selectFontForIndexPath:indexPath];
}

- (void)selectFontForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedRow inSection:0];
    
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    if([visibleIndexPaths containsObject:selectedIndexPath])
    {
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedCell.textLabel.text = [[[self class] getFontFamilies] objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [@"\u2713 " stringByAppendingString:[[[self class] getFontFamilies] objectAtIndex:indexPath.row]];
    
    self.selectedRow = indexPath.row;
    
    [self.richTextViewController.richEditor updateFontInRange:self.richTextViewController.richEditor.selectedTextRange
                                           withFontFamilyName:[[[self class] getFontFamilies] objectAtIndex:indexPath.row]
                                                    pointSize:12.0];
}

@end
