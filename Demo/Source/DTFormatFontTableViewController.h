//
//  DTRichTextEditorFontTableViewController.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 12/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DTRichTextEditorViewController;

@interface DTRichTextEditorFontTableViewController : UITableViewController

@property (nonatomic, assign) DTRichTextEditorViewController *richTextViewController;


@property (nonatomic, strong) NSString *fontFamilyName;

@end
