//
//  DTRichTextEditorViewController.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTRichTextEditorView.h"


@interface DTRichTextEditorViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

	IBOutlet DTRichTextEditorView *richEditor;
}

@end

