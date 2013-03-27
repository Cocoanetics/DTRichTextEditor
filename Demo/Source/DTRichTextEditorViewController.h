//
//  DTRichTextEditorViewController.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTRichTextEditorView.h"

@class DTRichTextEditorTestState;

@interface DTRichTextEditorViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, DTAttributedTextContentViewDelegate, DTRichTextEditorViewDelegate> {

	IBOutlet DTRichTextEditorView *richEditor;
	
	UITextRange *lastSelection;
	
    UIPopoverController *popover;
    
    NSCache *_imageViewCache;
	
	
	// demonstrating inputAccessoryView
	UIToolbar *toolbar;
	UIBarButtonItem *photoButton;
	
	// font toggling
	UIBarButtonItem *boldButton;
	UIBarButtonItem *italicButton;
	UIBarButtonItem *underlineButton;
    UIBarButtonItem *highlightButton;
    UIBarButtonItem *fontButton;
	
	// paragraph alignment buttons
	UIBarButtonItem *leftAlignButton;
	UIBarButtonItem *centerAlignButton;
	UIBarButtonItem *rightAlignButton;
	UIBarButtonItem *justifyAlignButton;
	
	// indent buttons
	UIBarButtonItem *increaseIndentButton;
	UIBarButtonItem *decreaseIndentButton;
	
	// lists
	UIBarButtonItem *unorderedListButton;
	UIBarButtonItem *orderedListButton;
	
	// URL
	UIBarButtonItem *linkButton;
}

@property (nonatomic, retain) NSCache *imageViewCache;

@property (nonatomic, retain) DTRichTextEditorTestState *testState;
@property (nonatomic, retain) UIPopoverController *testOptionsPopover;
@end

