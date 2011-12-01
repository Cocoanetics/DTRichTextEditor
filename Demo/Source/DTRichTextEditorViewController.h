//
//  DTRichTextEditorViewController.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTRichTextEditorView.h"

@interface DTRichTextEditorViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, DTAttributedTextContentViewDelegate> {

	IBOutlet DTRichTextEditorView *richEditor;
	
	UITextRange *lastSelection;
	
	BOOL isDirty;
    UIPopoverController *popover;
    
    NSCache *_imageViewCache;
	
	
	// demonstrating inputAccessoryView
	UIToolbar *toolbar;
	UIBarButtonItem *photoButton;
	
	UIBarButtonItem *boldButton;
	UIBarButtonItem *italicButton;
	UIBarButtonItem *underlineButton;
}

@property (nonatomic, retain) NSCache *imageViewCache;
@end

