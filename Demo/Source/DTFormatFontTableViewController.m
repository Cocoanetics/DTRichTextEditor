//
//  DTRichTextEditorFontTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorFontTableViewController.h"
#import "DTRichTextEditorFontFamilyTableViewController.h"
#import "DTRichTextEditorViewController.h"
#import "DTRichTextEditorView+Manipulation.h"

@interface DTRichTextEditorFontTableViewController ()
@property (nonatomic, assign) NSInteger selectedRow;
@end

@implementation DTRichTextEditorFontTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.selectedRow = -1;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[DTRichTextEditorFontFamilyTableViewController getFontsForFamily:self.fontFamilyName] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = self.selectedRow == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    NSString *fontName = [[DTRichTextEditorFontFamilyTableViewController getFontsForFamily:self.fontFamilyName] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = fontName;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    self.selectedRow = indexPath.row;
        
    NSArray *visibleCells = [self.tableView visibleCells];
    NSArray *filteredArray = [visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessoryType == %d", UITableViewCellAccessoryCheckmark]];
    UITableViewCell *lastCell = [filteredArray lastObject];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.richTextViewController.richEditor updateFontInRange:self.richTextViewController.richEditor.selectedTextRange
                                           withFontFamilyName:[[DTRichTextEditorFontFamilyTableViewController getFontsForFamily:self.fontFamilyName] objectAtIndex:indexPath.row]
                                                    pointSize:12.0];

}

@end
