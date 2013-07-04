//
//  DTFormatMediaTableViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 23/05/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTFormatOtherViewController.h"
#import "DTFormatViewController.h"

@interface DTFormatOtherViewController () <UIAlertViewDelegate>
@property (nonatomic, weak) DTFormatViewController<DTInternalFormatProtocol> *formatPicker;
@end

@implementation DTFormatOtherViewController

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320.0f, 320.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.formatPicker = (DTFormatViewController<DTInternalFormatProtocol> *)self.navigationController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellValue1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( !cell ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"Hyperlink";
    cell.detailTextLabel.text = self.formatPicker.hyperlink ? [self.formatPicker.hyperlink absoluteString] : @"None";
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hyperlink" message:@"Enter a URL for your hyperlink" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Make Link", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setText:[self.formatPicker.hyperlink absoluteString] ];
    
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        UITextField *linkTextField = [alertView textFieldAtIndex:0];

        NSURL *url = [NSURL URLWithString:linkTextField.text];
        
        [self.formatPicker applyHyperlinkToSelectedText:url];
        
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
