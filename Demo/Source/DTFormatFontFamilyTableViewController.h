//
//  DTRichTextEditorFontFamilyTableViewController.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTRichTextEditorFontFamilyTableViewController : UITableViewController

+ (NSArray *)getFontsForFamily:(NSString *)fontFamily __attribute__((const));

@end
