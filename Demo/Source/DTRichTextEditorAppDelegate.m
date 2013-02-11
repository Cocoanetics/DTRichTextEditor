//
//  DTRichTextEditorAppDelegate.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorAppDelegate.h"
#import "DTRichTextEditorViewController.h"
#import "DTRichTextEditor.h"


#pragma mark Pseudo implementation
@interface DTRichTextEditor_CrashTestView : UIView {
    DTRichTextEditorView *document;
}
@end

// Subview implementation
@implementation DTRichTextEditor_CrashTestView
- (id) init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildInterface];
    }
    return self;
}

- (void) buildInterface {
    NSLog(@"buildInterface called");
    document = [[DTRichTextEditorView alloc] init];
    [document setEditable:NO];
    
    document.defaultFontFamily = @"Helvetica";
    
    [self addSubview:document];
}

- (void) setHtmlContent:(NSString *) htmlText {
    NSLog(@"SetHtmlContent called");
    [document setHTMLString:htmlText];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [document setFrame:self.bounds];
}



@end

#pragma mark ViewController testcase
@interface DTRichTextEditorView_TestCase : UIViewController {
    DTRichTextEditor_CrashTestView *document;
} @end

@implementation DTRichTextEditorView_TestCase

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        document = [[DTRichTextEditor_CrashTestView alloc] init];
        NSURL *url = [NSURL URLWithString:@"http://loripsum.net/api/decorate/verylong/25/ul/ol/dl/bq/code/headers"];
        [document setHtmlContent:[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil]];
        document.alpha = 0;
       // [document setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        [self.view addSubview:document];
        
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
}

-(void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.5 animations:^{
        document.alpha = 1;
    }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //P : 1024x655
    //L : 768x911
    BOOL ls = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    [document setFrame:CGRectMake(0, 0, ls?1024:768, ls?655:911)];
}

@end


@implementation DTRichTextEditorAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{  
	// create a window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
//	// create the VC
//	viewController = [[DTRichTextEditorViewController alloc] init];
//	navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//	navController.navigationBarHidden = NO;
//	viewController.title = @"Rich Text Demo";
//	
//	// set it as root
//	self.window.rootViewController = navController;
    
    
    UIViewController *vc = [[DTRichTextEditorView_TestCase alloc] init];
    self.window.rootViewController = vc;
//
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
