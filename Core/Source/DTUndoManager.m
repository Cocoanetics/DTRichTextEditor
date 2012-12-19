//
//  DTUndoManager.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 19.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DTUndoManager.h"

@implementation DTUndoManager
{
	NSUInteger _numberOfOpenGroups;
}

- (void)beginUndoGrouping
{
	_numberOfOpenGroups++;
	
	[super beginUndoGrouping];
}

- (void)endUndoGrouping
{
	_numberOfOpenGroups--;
	
	[super endUndoGrouping];
}

- (void)closeAllOpenGroups
{
	while (_numberOfOpenGroups>0)
	{
		[self endUndoGrouping];
	}
}

- (void)undo
{
	[self closeAllOpenGroups];
	
	[super undo];
}

#pragma mark - Properties

@synthesize numberOfOpenGroups = _numberOfOpenGroups;

@end
