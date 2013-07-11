//
//  DTRichTextEditorViewController.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorViewController.h"
#import "NSAttributedString+HTML.h"
#import "NSAttributedString+DTRichText.h"
#import "DTRichTextEditor.h"

#import "DTRichTextEditorTestState.h"
#import "DTRichTextEditorTestStateController.h"
#import "DTCoreTextLayoutFrame.h"

#import "DTFormatViewController.h"

NSString *DTTestStateDataKey = @"DTTestStateDataKey";

@implementation DTRichTextEditorViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    richEditor = [[DTRichTextEditorView alloc] initWithFrame:view.bounds];
    richEditor.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    richEditor.textDelegate = self;
    
    [view addSubview:richEditor];
    
    self.view = view;
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    // if you want to show the keyboard after appearing
    [richEditor becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize test state
    NSData *testStateData = [[NSUserDefaults standardUserDefaults] dataForKey:DTTestStateDataKey];
    
    if (testStateData)
    {
        self.testState = [NSKeyedUnarchiver unarchiveObjectWithData:testStateData];
    }
    else
    {
        self.testState = [[DTRichTextEditorTestState alloc] init];
        self.testState.editable = YES;
    }
    
    UIBarButtonItem *formatItem = [[UIBarButtonItem alloc] initWithTitle:@"Format"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(presentFormatOptions:)];

    UIBarButtonItem *insertItem = [[UIBarButtonItem alloc] initWithTitle:@"Insert"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(presentGallery:)];

    UIBarButtonItem *testStateItem = [[UIBarButtonItem alloc] initWithTitle:@"Test Options" style:UIBarButtonItemStyleBordered target:self action:@selector(presentTestOptions:)];
    self.navigationItem.rightBarButtonItems = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @[formatItem, insertItem, testStateItem] : @[formatItem, testStateItem];
    
	// defaults
    [DTCoreTextLayoutFrame setShouldDrawDebugFrames:self.testState.shouldDrawDebugFrames];
    
	richEditor.baseURL = [NSURL URLWithString:@"http://www.drobnik.com"];
    richEditor.textDelegate = self;
	richEditor.defaultFontFamily = @"Helvetica";
	richEditor.textSizeMultiplier = 1.0;
	richEditor.maxImageDisplaySize = CGSizeMake(300, 300);
    richEditor.autocorrectionType = UITextAutocorrectionTypeYes;
    richEditor.editable = self.testState.editable;
    richEditor.editorViewDelegate = self;
    richEditor.defaultFontSize = 30;
	
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:DTDefaultLinkDecoration];
	[defaults setObject:[UIColor colorWithHTMLName:@"purple"] forKey:DTDefaultLinkColor];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:DTProcessCustomHTMLAttributes]; 
	
    // demonstrate half em paragraph spacing
    DTCSSStylesheet *styleSheet = [[DTCSSStylesheet alloc] initWithStyleBlock:@"p {margin-bottom:0.5em} ol {margin-bottom:0.5em; -webkit-padding-start:40px;} ul {margin-bottom:0.5em;-webkit-padding-start:40px;}"];
    [defaults setObject:styleSheet forKey:DTDefaultStyleSheet];
    
	richEditor.textDefaults = defaults;
    
    // load initial string from file
	NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
	NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	[richEditor setHTMLString:html];
    
	// image as drawn by your custom views which you return in the delegate method
	richEditor.attributedTextContentView.shouldDrawImages = NO;
	
    highlightButton = [[UIBarButtonItem alloc] initWithTitle:@"H" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHighlight:)];
    	
	UIBarButtonItem *smile = [[UIBarButtonItem alloc] initWithTitle:@":)" style:UIBarButtonItemStyleBordered target:self action:@selector(insertSmiley:)];
	
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
	richEditor.inputAccessoryView = toolbar;
	
	[toolbar setItems:[NSArray arrayWithObjects:highlightButton, smile, nil]];
    
    // notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[richEditor removeObserver:self forKeyPath:@"selectedTextRange"];
	
    popover.delegate = nil;
}

#pragma mark Helpers

- (void)replaceCurrentSelectionWithPhoto:(UIImage *)image
{	
	// make an attachment
	DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc] initWithElement:nil options:nil];
	attachment.image = (id)image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	
	[richEditor replaceRange:[richEditor selectedTextRange] withAttachment:attachment inParagraph:YES];
}


#pragma mark Actions


- (void)insertSmiley:(UIBarButtonItem *)sender
{
	if (![richEditor selectedTextRange])
	{
		NSLog(@"no text selected!");
		return;
	}
	
	UIImage *image = [UIImage imageNamed:@"icon_smile.gif"];
	
	// make an attachment
	DTImageTextAttachment *attachment = [[DTImageTextAttachment alloc] initWithElement:nil options:nil];
	attachment.image = image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	attachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
	
	[richEditor replaceRange:[richEditor selectedTextRange ] withAttachment:attachment inParagraph:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    popover = nil;
}

- (void)toggleHighlight:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleHighlightInRange:range color:[UIColor yellowColor]];
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
    NSNumber *cacheKey = [NSNumber numberWithUnsignedInteger:[attachment hash]];
    
    UIImageView *imageView = [self.imageViewCache objectForKey:cacheKey];
    
    if (imageView)
    {
        imageView.frame = frame;
        return imageView;
    }
    
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
	{
        DTImageTextAttachment *imageAttachment = (DTImageTextAttachment *)attachment;
        
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = imageAttachment.image;
        
        [self.imageViewCache setObject:imageView forKey:cacheKey];
        
        return imageView;
    }
    
	
	return nil;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = url;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	//UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	//[button addGestureRecognizer:longPress];
	
	return button;
}

- (void)linkPushed:(id)sender
{
	// do something when a link was pushed
}


#pragma mark - Presenting Test Options

@synthesize testOptionsPopover = _testOptionsPopover;

- (void)presentTestOptions:(id)sender
{
    if(!self.testStateController){
        DTRichTextEditorTestStateController *controller = [[DTRichTextEditorTestStateController alloc] initWithStyle:UITableViewStylePlain];
        controller.testState = self.testState;
        controller.completion = ^(DTRichTextEditorTestState *modifiedTestState) {
            // Store test state in user defaults
            NSData *testStateData = [NSKeyedArchiver archivedDataWithRootObject:modifiedTestState];
            [[NSUserDefaults standardUserDefaults] setObject:testStateData forKey:DTTestStateDataKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Update editable
            richEditor.editable = modifiedTestState.editable;
            
            // Update debug frames
            [DTCoreTextLayoutFrame setShouldDrawDebugFrames:modifiedTestState.shouldDrawDebugFrames];
            [richEditor.attributedTextContentView setNeedsDisplay];
        };
        
        self.testStateController = controller;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.testOptionsPopover == nil)
        {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.testStateController];
            UIPopoverController *toPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
            
            self.testOptionsPopover = toPopover;
        }
        
        [self.testOptionsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.testOptionsPopover.passthroughViews = nil;
    }
    else
    {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.testStateController];
        
        [self presentViewController:navController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark - Presenting Format Options

@synthesize formatOptionsPopover = _formatOptionsPopover;

- (void)presentFormatOptions:(id)sender
{
    if (!self.formatViewController)
    {
        DTFormatViewController *controller = [[DTFormatViewController alloc] init];
        controller.formatDelegate = self;
        self.formatViewController = controller;
    }
    
    [self.formatViewController popToRootViewControllerAnimated:NO];
    self.formatViewController.fontDescriptor = [richEditor fontDescriptorForRange:richEditor.selectedTextRange];
    
    NSDictionary *attributesDictionary = [richEditor typingAttributesForRange:richEditor.selectedTextRange];
    
    self.formatViewController.underline = (attributesDictionary[@"NSUnderline"] != nil);
    self.formatViewController.strikethrough = (attributesDictionary[@"NSStrikethrough"] != nil);
    
    CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[attributesDictionary objectForKey:(id)kCTParagraphStyleAttributeName];
    DTCoreTextParagraphStyle *dtstyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paragraphStyle];
    CFRelease(paragraphStyle);
    CTTextAlignment ali = dtstyle.alignment;
    self.formatViewController.textAlignment = ali;
    
    NSArray *listTypes = attributesDictionary[@"DTTextLists"];
    DTCSSListStyle *style = [listTypes lastObject];
    DTCSSListStyleType listType = style.type;
    self.formatViewController.listType = listType;
    
    self.formatViewController.hyperlink = attributesDictionary[@"NSLinkAttributeName"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.formatOptionsPopover == nil)
        {
            UIPopoverController *toPopover = [[UIPopoverController alloc] initWithContentViewController:self.formatViewController];
            
            self.formatOptionsPopover = toPopover;
        }
        
        [self.formatOptionsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.formatOptionsPopover.passthroughViews = nil;
        
    }
	else
	{
		richEditor.inputAccessoryView = nil; // no accessory on next inputView change
		[richEditor setInputView:self.formatViewController.view animated:YES];
    }
}

- (void)presentGallery:(id)sender
{
    if (!self.formatViewController)
    {
        DTFormatViewController *controller = [[DTFormatViewController alloc] init];
        controller.formatDelegate = self;
        self.formatViewController = controller;
    }
    
    UIImagePickerController *mediaController = [[UIImagePickerController alloc] init];
    mediaController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaController.allowsEditing = YES;
    mediaController.delegate = (DTFormatViewController<DTInternalFormatProtocol>*)self.formatViewController;

    [self presentViewController:mediaController animated:YES completion:NULL];
}


#pragma mark - DTRichTextEditorViewDelegate

- (BOOL)editorViewShouldBeginEditing:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewShouldBeginEditing:");
    return !self.testState.blockShouldBeginEditing;
}

- (void)editorViewDidBeginEditing:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewDidBeginEditing:");
}

- (BOOL)editorViewShouldEndEditing:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewShouldEndEditing:");
    return !self.testState.blockShouldEndEditing;
}

- (void)editorViewDidEndEditing:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewDidEndEditing:");
}

- (BOOL)editorView:(DTRichTextEditorView *)editorView shouldChangeTextInRange:(NSRange)range replacementText:(NSAttributedString *)text
{
    NSLog(@"editorView:shouldChangeTextInRange:replacementText:");
    
    return YES;
}

- (void)editorViewDidChangeSelection:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewDidChangeSelection:");
    
    if( self.formatViewController && [richEditor inputView] == self.formatViewController.view ){
        self.formatViewController.fontDescriptor = [richEditor fontDescriptorForRange:richEditor.selectedTextRange];
    }
}

- (void)editorViewDidChange:(DTRichTextEditorView *)editorView
{
    NSLog(@"editorViewDidChange:");
}

@synthesize menuItems = _menuItems;

- (NSArray *)menuItems
{
    if (_menuItems == nil)
    {
        UIMenuItem *insertItem = [[UIMenuItem alloc] initWithTitle:@"Insert" action:@selector(displayInsertMenu:)];
        UIMenuItem *insertStarItem = [[UIMenuItem alloc] initWithTitle:@"★" action:@selector(insertStar:)];
        UIMenuItem *insertCheckItem = [[UIMenuItem alloc] initWithTitle:@"☆" action:@selector(insertWhiteStar:)];
        _menuItems = @[insertItem, insertStarItem, insertCheckItem];
    }
    
    return _menuItems;
}

- (BOOL)editorView:(DTRichTextEditorView *)editorView canPerformAction:(SEL)action withSender:(id)sender
{
    DTTextRange *selectedTextRange = (DTTextRange *)editorView.selectedTextRange;
    BOOL hasSelection = ![selectedTextRange isEmpty];
    
    if (action == @selector(insertStar:) || action == @selector(insertWhiteStar:))
    {
        return _showInsertMenu;
    }
    
    if (_showInsertMenu)
    {
        return NO;
    }
    
    if (action == @selector(displayInsertMenu:))
    {
        return (!hasSelection && _showInsertMenu == NO);
    }
    
    // For fun, disable selectAll:
    if (action == @selector(selectAll:))
    {
        return NO;
    }
    
    return YES;
}

- (void)menuDidHide:(NSNotification *)notification
{
    _showInsertMenu = NO;
}

- (void)displayInsertMenu:(id)sender
{
    _showInsertMenu = YES;
    
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (void)insertStar:(id)sender
{
    _showInsertMenu = NO;
    
    [richEditor insertText:@"★"];
}

- (void)insertWhiteStar:(id)sender
{
    _showInsertMenu = NO;
    
    [richEditor insertText:@"☆"];
}


#pragma mark Properties

- (NSCache *)imageViewCache
{
    if (!_imageViewCache)
    {
        _imageViewCache = [[NSCache alloc] init];
    }
    
    return _imageViewCache;
}

@synthesize imageViewCache = _imageViewCache;

#pragma mark - DTFormatDelegate
- (void)formatDidSelectFont:(DTCoreTextFontDescriptor *)font
{
    [richEditor updateFontInRange:richEditor.selectedTextRange
               withFontFamilyName:font.fontFamily
                        pointSize:font.pointSize];
}

- (void)formatDidToggleBold
{
    [richEditor toggleBoldInRange:richEditor.selectedTextRange];
}

- (void)formatDidToggleItalic
{
    [richEditor toggleItalicInRange:richEditor.selectedTextRange];
}

- (void)formatDidToggleUnderline
{
    [richEditor toggleUnderlineInRange:richEditor.selectedTextRange];
}

- (void)formatDidToggleStrikethrough
{
    [richEditor toggleStrikethroughInRange:richEditor.selectedTextRange];
}

- (void)formatViewControllerUserDidFinish:(DTFormatViewController *)formatController
{
    // called only by tapping `done` in iPhone UI
    
	richEditor.inputAccessoryView = toolbar; // restore accessory on next inputView change
	[richEditor setInputView:nil animated:YES];
}

- (void)formatDidChangeTextAlignment:(CTTextAlignment)alignment
{
    UITextRange *range = richEditor.selectedTextRange;
	[richEditor applyTextAlignment:alignment toParagraphsContainingRange:range];
}

- (void)increaseTabulation
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor changeParagraphLeftMarginBy:36 toParagraphsContainingRange:range];
}

- (void)decreaseTabulation
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor changeParagraphLeftMarginBy:-36 toParagraphsContainingRange:range];
}

- (void)toggleListType:(DTCSSListStyleType)listType
{
    UITextRange *range = richEditor.selectedTextRange;
	
	DTCSSListStyle *listStyle = [[DTCSSListStyle alloc] init];
	listStyle.startingItemNumber = 1;
    listStyle.position = listType;
	listStyle.type = listType;
	
	[richEditor toggleListStyle:listStyle inRange:range];
}

- (void)applyHyperlinkToSelectedText:(NSURL *)url
{
    UITextRange *range = richEditor.selectedTextRange;
    
    [richEditor toggleHyperlinkInRange:range URL:url];
}


@end
