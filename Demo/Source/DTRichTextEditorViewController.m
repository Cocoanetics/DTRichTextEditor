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
    
	// defaults
	richEditor.baseURL = [NSURL URLWithString:@"http://www.drobnik.com"];
    richEditor.textDelegate = self;
	richEditor.defaultFontFamily = @"Helvetica";
	richEditor.textSizeMultiplier = 2.2;
	richEditor.maxImageDisplaySize = CGSizeMake(300, 300);
    richEditor.autocorrectionType = UITextAutocorrectionTypeNo;
	
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:DTDefaultLinkDecoration];
	[defaults setObject:[UIColor colorWithHTMLName:@"purple"] forKey:DTDefaultLinkColor];
	
	richEditor.textDefaults = defaults;
   
    NSString *html = @"<p><span style=\"color:red;\">Hello</span> <b>bold</b> <i>italic</i> <span style=\"color: green;font-family:Courier;\">World!</span></p>";
	[richEditor setHTMLString:html];

    [richEditor setFont:[UIFont boldSystemFontOfSize:30]];
//	[DTCoreTextLayoutFrame setShouldDrawDebugFrames:YES];
	
	// image as drawn by your custom views which you return in the delegate method
	richEditor.attributedTextContentView.shouldDrawImages = NO;
	
	photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(insertPhoto:)];
	photoButton.enabled = NO;
	
	boldButton = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleBold:)];
	boldButton.enabled = NO;

	italicButton = [[UIBarButtonItem alloc] initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleItalic:)];
	italicButton.enabled = NO;

	underlineButton = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleUnderline:)];
	underlineButton.enabled = NO;
    
    highlightButton = [[UIBarButtonItem alloc] initWithTitle:@"H" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHighlight:)];
	highlightButton.enabled = NO;
    
    fontButton = [[UIBarButtonItem alloc] initWithTitle:@"Font" style:UIBarButtonItemStyleBordered target:self action:@selector(changeFont:)];
	fontButton.enabled = NO;
    
    

	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	leftAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"L" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleLeft:)];
	centerAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"C" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCenter:)];
	rightAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"R" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleRight:)];
	justifyAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"J" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleJustify:)];
	
	increaseIndentButton = [[UIBarButtonItem alloc] initWithTitle:@"->" style:UIBarButtonItemStyleBordered target:self action:@selector(increaseIndent:)];
	decreaseIndentButton = [[UIBarButtonItem alloc] initWithTitle:@"<-" style:UIBarButtonItemStyleBordered target:self action:@selector(decreaseIndent:)];
	
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	UIBarButtonItem *spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	orderedListButton = [[UIBarButtonItem alloc] initWithTitle:@"1." style:UIBarButtonItemStyleBordered target:self action:@selector(toggleOrderedList:)];
	unorderedListButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleUnorderedList:)];

	UIBarButtonItem *spacer4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem *smile = [[UIBarButtonItem alloc] initWithTitle:@":)" style:UIBarButtonItemStyleBordered target:self action:@selector(insertSmiley:)];
	

	linkButton = [[UIBarButtonItem alloc] initWithTitle:@"URL" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleURL:)];
	
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
	richEditor.inputAccessoryView = toolbar;
	
	[toolbar setItems:[NSArray arrayWithObjects:boldButton, italicButton, underlineButton, highlightButton, fontButton, spacer, leftAlignButton, centerAlignButton, rightAlignButton, justifyAlignButton, spacer2, increaseIndentButton, decreaseIndentButton, spacer3, orderedListButton, unorderedListButton, spacer4, photoButton, smile, linkButton, nil]];
	
	// watch the selectedTextRange property
	[richEditor addObserver:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionNew context:nil];
	
	// notification for isDirty
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:DTRichTextEditorTextDidBeginEditingNotification object:richEditor];
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
	if (!lastSelection)
	{
		return;
	}
	
	// make an attachment
	DTTextAttachment *attachment = [[DTTextAttachment alloc] init];
	attachment.contents = (id)image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	attachment.contentType = DTTextAttachmentTypeImage;
	
	[richEditor replaceRange:lastSelection withAttachment:attachment inParagraph:YES];
}


#pragma mark Actions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        
        CGImageRef iref = [representation fullScreenImage];
        if (iref) {
            UIImage *theThumbnail = [UIImage imageWithCGImage:iref];
			[self replaceCurrentSelectionWithPhoto:theThumbnail];
        }
    };
	
	
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
	
    if(imageURL)
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL 
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
        [popover dismissPopoverAnimated:YES];
        popover = nil;
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)insertPhoto:(UIBarButtonItem *)sender
{
	// preserve last selection because this goes away when editor loses firstResponder
	lastSelection = [richEditor selectedTextRange];
	
	if (!lastSelection)
	{
		return;
	}
	
    if ([popover isPopoverVisible])
    {
        [popover dismissPopoverAnimated:YES];
        popover = nil;
        
        return;
    }
    
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.delegate = self;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		popover = [[UIPopoverController alloc] initWithContentViewController:picker];
		popover.delegate = self;
		[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
	{
		[self presentModalViewController:picker animated:YES];
	}
}

- (void)insertSmiley:(UIBarButtonItem *)sender
{
	if (![richEditor selectedTextRange])
	{
		NSLog(@"no text selected!");
		return;
	}
	
	UIImage *image = [UIImage imageNamed:@"icon_smile.gif"];
	
	// make an attachment
	DTTextAttachment *attachment = [[DTTextAttachment alloc] init];
	attachment.contents = (id)image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	attachment.contentType = DTTextAttachmentTypeImage;
	attachment.verticalAlignment = DTTextAttachmentVerticalAlignmentCenter;
	
	[richEditor replaceRange:[richEditor selectedTextRange ] withAttachment:attachment inParagraph:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    popover = nil;
}

- (void)toggleBold:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleBoldInRange:range];
}

- (void)toggleItalic:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleItalicInRange:range];
}

- (void)toggleUnderline:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleUnderlineInRange:range];
}

- (void)toggleHighlight:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleHighlightInRange:range color:[UIColor yellowColor]];
}

- (void)toggleLeft:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor applyTextAlignment:kCTLeftTextAlignment toParagraphsContainingRange:range];
}

- (void)toggleCenter:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor applyTextAlignment:kCTCenterTextAlignment toParagraphsContainingRange:range];
}

- (void)toggleRight:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor applyTextAlignment:kCTRightTextAlignment toParagraphsContainingRange:range];
}

- (void)toggleJustify:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor applyTextAlignment:kCTJustifiedTextAlignment toParagraphsContainingRange:range];
}

- (void)increaseIndent:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor changeParagraphLeftMarginBy:36 toParagraphsContainingRange:range];
}

- (void)decreaseIndent:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor changeParagraphLeftMarginBy:-36 toParagraphsContainingRange:range];
}

- (void)toggleUnorderedList:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	
	DTCSSListStyle *listStyle = [[DTCSSListStyle alloc] init];
	listStyle.startingItemNumber = 1;
	listStyle.type = DTCSSListStyleTypeDisc;
	
	[richEditor toggleListStyle:listStyle inRange:range];
}

- (void)toggleOrderedList:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	
	DTCSSListStyle *listStyle = [[DTCSSListStyle alloc] init];
	listStyle.startingItemNumber = 1;
	listStyle.type = DTCSSListStyleTypeDecimal;
	
	[richEditor toggleListStyle:listStyle inRange:range];
}

- (void)toggleURL:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	
	// for simplicity this is static
	NSURL *URL =[NSURL URLWithString:@"http://www.cocoanetics.com"];
	
	[richEditor toggleHyperlinkInRange:range URL:URL];
}

- (void)changeFont:(UIBarButtonItem *)sender
{
    UITextRange *range = richEditor.selectedTextRange;
    
    // for simplicity we set a static font, IRL you want to have a fancy font picker dialog
    
    // you can get the current font family and size (and other attributes like this:
    
    DTCoreTextFontDescriptor *fontDescriptor = [richEditor fontDescriptorForRange:range];
    NSLog(@"font-family: %@, size: %.0f", fontDescriptor.fontFamily, fontDescriptor.pointSize);
    
    [richEditor updateFontInRange:range withFontFamilyName:@"American Typewriter" pointSize:60];
}

#pragma mark Notifications
- (void)textChanged:(NSNotification *)notification
{
	isDirty = YES;
	//NSLog(@"Text Changed");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectedTextRange"])
	{
		id newRange = [change objectForKey:NSKeyValueChangeNewKey];
		
		// disable photo/bold button if there is no selection
		if (newRange == [NSNull null])
		{
			for (UIBarButtonItem *oneItem in toolbar.items)
			{
				oneItem.enabled = NO;
			}
		}
		else
		{
			for (UIBarButtonItem *oneItem in toolbar.items)
			{
				oneItem.enabled = YES;
			}
			
			if (richEditor.selectedTextRange.start)
			{
				lastSelection = richEditor.selectedTextRange;
			}
		}
	}
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
    
    if (attachment.contentType == DTTextAttachmentTypeImage)
	{
        imageView = [[UIImageView alloc] initWithFrame:frame];
        if ([attachment.contents isKindOfClass:[UIImage class]])
        {
            imageView.image = attachment.contents;
        }
        
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

@end
