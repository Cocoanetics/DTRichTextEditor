//
//  DTInputViewTableViewController.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 13.09.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

// table view controller that instantiates a table view that ignores setContentInset
// fix for rdar://13836932 - inputView gets contentInset set if keyboard is showing

@interface DTInputViewTableViewController : UITableViewController

@end
