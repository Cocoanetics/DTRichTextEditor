//
//  DTRichTextEditorTestState.h
//  DTRichTextEditor
//
//  Created by Lee Hericks on 3/21/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTRichTextEditorTestState : NSObject

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL blockShouldBeginEditing;
@property (nonatomic, assign) BOOL blockShouldEndEditing;

@end
