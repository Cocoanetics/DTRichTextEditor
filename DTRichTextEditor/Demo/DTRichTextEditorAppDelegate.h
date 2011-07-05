//
//  DTRichTextEditorAppDelegate.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTRichTextEditorViewController;

@interface DTRichTextEditorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DTRichTextEditorViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DTRichTextEditorViewController *viewController;

@end

