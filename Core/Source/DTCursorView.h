//
//  DTCursorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DTCursorViewDidBlink;

typedef enum 
{
	DTCursorStateBlinking = 0,
	DTCursorStateStatic
} DTCursorState;

@interface DTCursorView : UIView 

@property (nonatomic, assign) DTCursorState state;

@end
