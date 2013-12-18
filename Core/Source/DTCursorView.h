//
//  DTCursorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DTCursorViewDidBlink;

/**
 The current cursor state
 */
typedef NS_ENUM(NSUInteger, DTCursorState)
{
   /**
    Cursor is blinking
    */
	DTCursorStateBlinking = 0,
   
   /**
    Cursor is not blinking
    */
	DTCursorStateStatic
};

/**
 Class for representing a caret (aka cursor) in DTRichTextEditorView.
 
 The backgroundColor of the cursor view is the caret color, the default is the same blue that Apple uses.
 */
@interface DTCursorView : UIView 

/**
 @name Setting the State
 */

/**
 The current state of the cursor.
 
 Possible states are:
 
 -	DTCursorStateBlinking
 -	DTCursorStateStatic
 
 */
@property (nonatomic, assign) DTCursorState state;

@end
