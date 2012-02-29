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

#import <AssetsLibrary/AssetsLibrary.h>

@implementation DTRichTextEditorViewController



/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
    
    NSString *html = @"<p><span style=\"color:red;\">Hello</span> <b>bold</b> <i>italic</i> <span style=\"color: green;font-family:Courier;\">World!</span></p>";
	
//	[DTCoreTextLayoutFrame setShouldDrawDebugFrames:YES];
	
	[richEditor setHTMLString:html];
	
	// image as drawn by your custom views which you return in the delegate method
	richEditor.contentView.shouldDrawImages = NO;
	
	
	photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(insertPhoto:)];
	photoButton.enabled = NO;
	
	boldButton = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleBold:)];
	boldButton.enabled = NO;

	italicButton = [[UIBarButtonItem alloc] initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleItalic:)];
	italicButton.enabled = NO;

	underlineButton = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleUnderline:)];
	underlineButton.enabled = NO;

	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	leftAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"L" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleLeft:)];
	centerAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"C" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCenter:)];
	rightAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"R" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleRight:)];
	justifyAlignButton = [[UIBarButtonItem alloc] initWithTitle:@"J" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleJustify:)];
	
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
	richEditor.inputAccessoryView = toolbar;
	
	[toolbar setItems:[NSArray arrayWithObjects:boldButton, italicButton, underlineButton, spacer, leftAlignButton, centerAlignButton, rightAlignButton, justifyAlignButton, spacer2, photoButton, nil]];
	
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
	lastSelection = richEditor.selectedTextRange;
	
	if (!lastSelection)
	{
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
