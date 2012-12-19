//
//  DTUndoManager.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 19.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTUndoManager : NSUndoManager

@property (nonatomic, readonly) NSUInteger numberOfOpenGroups;

- (void)closeAllOpenGroups;

@end
