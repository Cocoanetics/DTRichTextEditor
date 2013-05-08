//
//  DTRichTextEditorFontFamilyTableViewController.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFormatFontFamilyTableViewController : UITableViewController

- (id)initWithStyle:(UITableViewStyle)style selectedFontFamily:(NSString *)selectedFontFamily;
- (void)setSelectedFontFamily:(NSString *)selectedFontFamily;

@end
