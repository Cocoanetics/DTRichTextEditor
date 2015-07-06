//
//  DTRichTextEditorConstants.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 09.04.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

// for savekeeping paragraph spacing while this paragraph is in a list so that it can be restored if the paragraph is taken out of the list
extern NSString * const DTParagraphSpacingOverriddenByListAttribute;

// for temporary keeping track of a selection range while modifying the attributed string in a complicated manner
extern NSString * const DTSelectionMarkerAttribute;