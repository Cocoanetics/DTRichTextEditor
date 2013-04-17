//
//  DTRichTextEditorFontTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatFontTableViewController.h"
#import "DTCoreTextFontCollection.h"
#import "DTCoreTextFontDescriptor.h"

#import "DTFormatFontFamilyTableViewController.h"
#import "DTFormatViewController.h"

@interface DTFormatFontTableViewController ()
@property (nonatomic, assign) NSInteger selectedRow;
@end

@implementation DTFormatFontTableViewController

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
    return self.fontDescriptors.count;
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
    
    DTCoreTextFontDescriptor *descriptor = self.fontDescriptors[indexPath.row];
    
    NSArray *traits = @[@"wide", @"thin", @"ultra", @"medium", @"light",  @"demi", @"heavy", @"black", @"condensed", @"roman", @"book", @"oblique", @"bold", @"italic"];
    NSMutableArray *containedTraits = [NSMutableArray array];
    for (NSString *trait in traits) {
        NSRange range = [descriptor.fontName rangeOfString:trait options:NSCaseInsensitiveSearch];
        
        if(range.location != NSNotFound)
           [containedTraits addObject:trait];
    }
    
    NSString *fontName = containedTraits.count > 0 ? [[containedTraits componentsJoinedByString:@" "] capitalizedString] : @"Regular";
    
    cell.textLabel.text = fontName;
    cell.textLabel.font = [UIFont fontWithName:descriptor.fontName size:18.0f];
    
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
    
    id<DTInternalFormatProtocol> formatController = (id<DTInternalFormatProtocol>)self.navigationController;
    DTCoreTextFontDescriptor *descriptor = self.fontDescriptors[indexPath.row];

    [formatController applyFont:descriptor];
}

@end
