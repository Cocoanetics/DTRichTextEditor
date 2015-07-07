//
//  DTUndoManager.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 19.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Specialized undo manager that automatically closes open undo groups.
 
 If you do an undo or removeAllActions then closeAllOpenGroups will be called. This is required because while typing you want all typed characters go into the same open undo group, but need to close the group in time before doing an undo, otherwise there will be a crash.
 */

@interface DTUndoManager : NSUndoManager

/**
 Number of currently open undo groups
 */
@property (nonatomic, readonly) NSUInteger numberOfOpenGroups;

/**
 Closes all open undo groups
 */
- (void)closeAllOpenGroups;

@end
