//
//  DTRichTextEditorViewController.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DTRichTextEditorViewController.h"
#import "NSAttributedString+HTML.h"

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
    [richEditor becomeFirstResponder];
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *html = @"<p style=\"font-size:40;\"><span style=\"color:red;\">Hello</span> <b>bold</b> <i>italic</i> <span style=\"color: green;font-family:Courier;\">World!</span></p>";
	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAttributedString *string = [[[NSAttributedString alloc] initWithHTML:data documentAttributes:NULL] autorelease];
	
	[richEditor setAttributedText:string];
	//[richEditor setPosition:[richEditor endOfDocument]];
	
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
    [super dealloc];
}

@end
