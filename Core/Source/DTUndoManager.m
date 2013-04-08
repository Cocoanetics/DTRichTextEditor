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
    if (_numberOfOpenGroups==0)
    {
        return;
    }
    
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

- (void)removeAllActions
{
	[self closeAllOpenGroups];
	[super removeAllActions];
}

- (void)undo
{
	[self closeAllOpenGroups];
	
	[super undo];
}

- (void)disableUndoRegistration
{
    [self closeAllOpenGroups];
    
    [super disableUndoRegistration];
}

- (void)enableUndoRegistration
{
    [self closeAllOpenGroups];
    
    [super enableUndoRegistration];
}

#pragma mark - Properties

@synthesize numberOfOpenGroups = _numberOfOpenGroups;

@end
