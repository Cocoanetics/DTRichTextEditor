//
//  DTRichTextEditorAppDelegate.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTRichTextEditorViewController;

@interface DTRichTextEditorAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DTRichTextEditorViewController *viewController;

@end
