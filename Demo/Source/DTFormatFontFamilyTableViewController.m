//
//  DTRichTextEditorFontFamilyTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>

#import "DTFormatFontFamilyTableViewController.h"
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
        [self setSelectedFontFamily:selectedFontFamily];
    }
    return self;
}

#pragma mark - Changing the selected font family

- (void)setSelectedFontFamily:(NSString *)selectedFontFamily
{
    self.selectedRow = [self.fontFamilies indexOfObjectPassingTest:^BOOL(DTCoreTextFontDescriptor *obj, NSUInteger idx, BOOL *stop) {
            return [obj.fontFamily isEqualToString:selectedFontFamily];
    }];
    
    if ([self isViewLoaded])
    {
        NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
        [self.tableView reloadRowsAtIndexPaths:visibleIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Font Family";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // on the phone this controller will be presented modally
        // we need a control to dismiss ourselves
        
        // add a bar button item to close
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"\u25BC"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:nil
                                                                     action:@selector(userPressedDone:)];
        self.navigationItem.rightBarButtonItem = closeItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	[self.tableView reloadData];
	
    // Scroll to initial selected font
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
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
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
    if ([visibleIndexPaths containsObject:oldSelectedIndexPath])
    {
        UITableViewCell *oldSelectedCell = [self.tableView cellForRowAtIndexPath:oldSelectedIndexPath];
        oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }

    if ([visibleIndexPaths containsObject:indexPath])
    {
        UITableViewCell *newSelectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        newSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    self.selectedRow = indexPath.row;

    // Apply the font
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    DTCoreTextFontDescriptor *fontDescriptor = self.fontFamilies[indexPath.row];
    [formatController applyFont:fontDescriptor];
}

@end
