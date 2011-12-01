//
//  DemoAppDelegate.h
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

@class DemoTextViewController;

@interface DemoAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *_window;
	UINavigationController *_navigationController;
}

@property (nonatomic, retain) UIWindow *window;

@end
