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

#import "DTFormatViewController.h"

@interface DTFormatFontFamilyTableViewController ()
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, retain) NSArray *fontFamilies;
@end

@implementation DTFormatFontFamilyTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.selectedRow = -1;
        NSArray *allDescriptors = [[DTCoreTextFontCollection availableFontsCollection] fontDescriptors];
        
        __block NSMutableArray *familyNames = [NSMutableArray array];
        __block NSMutableArray *familyDescriptors = [NSMutableArray array];
        
        [allDescriptors enumerateObjectsUsingBlock:^(DTCoreTextFontDescriptor *obj, NSUInteger idx, BOOL *stop) {
            if([familyNames containsObject:obj.fontFamily])
                return;
            
            [familyNames addObject:obj.fontFamily];
            [familyDescriptors addObject:obj];
        }];
        
        NSSortDescriptor *alphabeticalFontFamilyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fontFamily" ascending:YES];
        
        self.fontFamilies = [familyDescriptors sortedArrayUsingDescriptors:@[alphabeticalFontFamilyDescriptor]];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fontFamilies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...

    DTCoreTextFontDescriptor *fontDescriptor = self.fontFamilies[indexPath.row];
    
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

- (void)selectFontForIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedRow inSection:0];
    
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
        
    DTCoreTextFontDescriptor *fontDescriptor = self.fontFamilies[indexPath.row];
    
    if([visibleIndexPaths containsObject:selectedIndexPath])
    {
        DTCoreTextFontDescriptor *fontDescriptor_selected = self.fontFamilies[selectedIndexPath.row];
        
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
