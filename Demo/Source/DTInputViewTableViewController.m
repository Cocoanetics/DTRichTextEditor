//
//  DTInputViewTableViewController.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 13.09.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTInputViewTableViewController.h"
#import "DTTableView.h"

@interface DTInputViewTableViewController ()

@end

@implementation DTInputViewTableViewController

- (void)loadView
{
	DTTableView *tableView = [[DTTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;
	
	self.view = tableView;
}

@end
