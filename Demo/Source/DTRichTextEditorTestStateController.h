//
//  DTRichTextEditorTestStateController.h
//  DTRichTextEditor
//
//  Created by Lee Hericks on 3/21/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTRichTextEditorTestState;

@interface DTRichTextEditorTestStateController : UITableViewController

@property (nonatomic, strong) DTRichTextEditorTestState *testState;
@property (nonatomic, copy) void (^completion)(DTRichTextEditorTestState *testState);

@end
