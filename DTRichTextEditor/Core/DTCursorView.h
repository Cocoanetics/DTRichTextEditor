//
//  DTCursorView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const DTCursorViewDidBlink;

@interface DTCursorView : UIView 
{
	NSTimer *blinkingTimer;
}

@end
