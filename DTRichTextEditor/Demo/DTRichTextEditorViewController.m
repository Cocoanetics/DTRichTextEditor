//
//  DTRichTextEditorViewController.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
	
	NSString *html = @"<p style=\"font-size:40;\"><span style=\"color:red;\">Hello</span> <b>bold</b> <i>italic</i> <span style=\"color: green;font-family:Courier;\">World!</span></p>";
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *string = [[[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL] autorelease];
	
	[richEditor setAttributedText:string];
	//[richEditor setPosition:[richEditor endOfDocument]];
	
	UIBarButtonItem *photo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(insertPhoto:)];
	self.navigationItem.rightBarButtonItem = photo;
	[photo release];
	
	UIBarButtonItem *bold = [[UIBarButtonItem alloc] initWithTitle:@"Bold" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleBold:)];
	self.navigationItem.leftBarButtonItem = bold;
	[bold release];
	
	richEditor.contentView.shouldDrawImages = YES;
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


- (void)dealloc {
	[lastSelection release];
    [super dealloc];
}

#pragma mark Helpers

- (void)replaceCurrentSelectionWithPhoto:(UIImage *)image
{
	if (!lastSelection)
	{
		return;
	}
	
	// make an attachment
	DTTextAttachment *attachment = [[[DTTextAttachment alloc] init] autorelease];
	attachment.contents = (id)image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	attachment.contentType = DTTextAttachmentTypeImage;
	
	[richEditor replaceRange:lastSelection withAttachment:attachment];
}


#pragma mark Actions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        CGImageRef iref = [myasset thumbnail];
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
        ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        [assetslibrary assetForURL:imageURL 
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
	
    [self dismissModalViewControllerAnimated:YES];
}

- (void)insertPhoto:(UIBarButtonItem *)sender
{
	// preserve last selection because this goes away when editor loses firstResponder
	[lastSelection release];
	lastSelection = [richEditor.selectedTextRange retain];
	
	if (!lastSelection)
	{
		return;
	}
	
	UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.delegate = self;
	[self presentModalViewController:picker animated:YES];
}

- (void)toggleBold:(UIBarButtonItem *)sender
{
	UITextRange *range = richEditor.selectedTextRange;
	[richEditor toggleBoldStyleInRange:range];
}

@end
