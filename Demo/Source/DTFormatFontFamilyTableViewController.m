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

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style selectedFontFamily:(NSString *)selectedFontFamily
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
        self.selectedRow = [self.fontFamilies indexOfObjectPassingTest:^BOOL(DTCoreTextFontDescriptor *obj, NSUInteger idx, BOOL *stop) {
            return [obj.fontFamily isEqualToString:selectedFontFamily];
        }];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll to initial selected font
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
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

    DTCoreTextFontDescriptor *fontDescriptor = self.fontFamilies[indexPath.row];
    
    cell.textLabel.text = fontDescriptor.fontFamily;
    cell.textLabel.font = [UIFont fontWithName:fontDescriptor.fontFamily size:18.0f];
    cell.accessoryType = (self.selectedRow == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.selectedRow)
        [self selectFontForIndexPath:indexPath];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)selectFontForIndexPath:(NSIndexPath *)indexPath
{
    // Update the cells
    NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForItem:self.selectedRow inSection:0];
    NSIndexPath *newSelectedIndexPath = indexPath;
    self.selectedRow = indexPath.row;
    [self.tableView reloadRowsAtIndexPaths:@[oldSelectedIndexPath, newSelectedIndexPath]
                          withRowAnimation:UITableViewRowAnimationNone];

    // Apply the font
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    DTCoreTextFontDescriptor *fontDescriptor = self.fontFamilies[indexPath.row];
    [formatController applyFont:fontDescriptor];
}

@end
