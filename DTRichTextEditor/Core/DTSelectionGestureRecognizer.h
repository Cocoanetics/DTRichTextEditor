//
//  DTSelectionGestureRecognizer.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
	DTSelectionStateUnknown = 0,
	DTSelectionStateTap,
	DTSelectionStateLongPress,
	DTSelectionStateDragging
} DTSelectionState;

@interface DTSelectionGestureRecognizer : UIGestureRecognizer
{
	NSTimeInterval firstTouchTimestamp;
	NSTimeInterval latestTouchTimestamp;
	
	CGPoint firstTouchPoint;
	
	DTSelectionState _selectionState;
	BOOL _didDrag;
}

@property (nonatomic, readonly) DTSelectionState selectionState;

@end
