//
//  DTRichTextEditorFontFamilyTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatFontFamilyTableViewController.h"
#import "DTCoreTextFontCollection.h"
#import "DTCoreTextFontDescriptor.h"

#import "DTFormatFontTableViewController.h"
#import "DTFormatViewController.h"

@interface DTFormatFontFamilyTableViewController ()
@property (nonatomic, assign) NSInteger selectedRow;
@end

@implementation DTFormatFontFamilyTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.selectedRow = -1;
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[DTCoreTextFontCollection availableFontsCollection] fontFamilyDescriptors] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    DTCoreTextFontCollection *fontCollection = [DTCoreTextFontCollection availableFontsCollection];
    
    NSDictionary *fontObject = [[fontCollection fontFamilyDescriptors] objectAtIndex:indexPath.row];
    
    DTCoreTextFontDescriptor *fontDescriptor = fontObject[@"font"];
    
    cell.accessoryType = [fontObject[@"variations"] boolValue] ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;

    
    cell.textLabel.text = fontDescriptor.fontFamily;
    cell.textLabel.font = [UIFont fontWithName:fontDescriptor.fontFamily size:18.0f];

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
    DTFormatFontTableViewController *fontController = [[DTFormatFontTableViewController alloc] initWithStyle:UITableViewStyleGrouped];

    DTCoreTextFontCollection *fontCollection = [DTCoreTextFontCollection availableFontsCollection];
    
    NSDictionary *fontObject = [[fontCollection fontFamilyDescriptors] objectAtIndex:indexPath.row];
    
    DTCoreTextFontDescriptor *fontDescriptor = fontObject[@"font"];
    
    fontController.fontFamilyName = fontDescriptor.fontFamily;
    
    [self.navigationController pushViewController:fontController animated:YES];
        
    [self selectFontForIndexPath:indexPath];
}

- (void)selectFontForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedRow inSection:0];
    
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    DTCoreTextFontCollection *fontCollection = [DTCoreTextFontCollection availableFontsCollection];
    
    NSDictionary *fontObject = [[fontCollection fontFamilyDescriptors] objectAtIndex:indexPath.row];
    
    DTCoreTextFontDescriptor *fontDescriptor = fontObject[@"font"];
    
    if([visibleIndexPaths containsObject:selectedIndexPath])
    {
        NSDictionary *fontObject_selected = [[fontCollection fontFamilyDescriptors] objectAtIndex:selectedIndexPath.row];
        DTCoreTextFontDescriptor *fontDescriptor_selected = fontObject_selected[@"font"];

        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedCell.textLabel.text = fontDescriptor_selected.fontFamily;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [@"\u2713 " stringByAppendingString:fontDescriptor.fontFamily];
    
    self.selectedRow = indexPath.row;
    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
        
    [formatController applyFont:fontDescriptor];
}

@end
