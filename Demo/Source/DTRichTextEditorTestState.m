//
//  DTRichTextEditorTestState.m
//  DTRichTextEditor
//
//  Created by Lee Hericks on 3/21/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorTestState.h"

@implementation DTRichTextEditorTestState

@synthesize shouldDrawDebugFrames = _shouldDrawDebugFrames;
@synthesize editable = _editable;
@synthesize blockShouldBeginEditing = _blockShouldBeginEditing;
@synthesize blockShouldEndEditing = _blockShouldEndEditing;

#pragma mark - NSCoding

NSString *DTTestStateShouldDrawDebugFramesKey = @"DTTestStateShouldDrawDebugFramesKey";
NSString *DTTestStateEditableKey = @"DTTestStateEditableKey";
NSString *DTTestStateBlockShouldBeginEditingKey = @"DTTestStateBlockShouldBeginEditingKey";
NSString *DTTestStateBlockShouldEndEditingKey = @"DTTestStateBlockShouldEndEditingKey";

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.shouldDrawDebugFrames forKey:DTTestStateShouldDrawDebugFramesKey];
    [aCoder encodeBool:self.editable forKey:DTTestStateEditableKey];
    [aCoder encodeBool:self.blockShouldBeginEditing forKey:DTTestStateBlockShouldBeginEditingKey];
    [aCoder encodeBool:self.blockShouldEndEditing forKey:DTTestStateBlockShouldEndEditingKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        _shouldDrawDebugFrames = [aDecoder decodeBoolForKey:DTTestStateShouldDrawDebugFramesKey];
        _editable = [aDecoder decodeBoolForKey:DTTestStateEditableKey];
        _blockShouldBeginEditing = [aDecoder decodeBoolForKey:DTTestStateBlockShouldBeginEditingKey];
        _blockShouldEndEditing = [aDecoder decodeBoolForKey:DTTestStateBlockShouldEndEditingKey];
    }
    
    return self;
}

@end
