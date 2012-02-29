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
	
	// font toggling
	UIBarButtonItem *boldButton;
	UIBarButtonItem *italicButton;
	UIBarButtonItem *underlineButton;
	
	// paragraph alignment buttons
	UIBarButtonItem *leftAlignButton;
	UIBarButtonItem *centerAlignButton;
	UIBarButtonItem *rightAlignButton;
	UIBarButtonItem *justifyAlignButton;
}

@property (nonatomic, retain) NSCache *imageViewCache;
@end

