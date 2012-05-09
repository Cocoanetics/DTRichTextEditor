//
//  NSMutableDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+DTRichText.h"

@interface NSMutableDictionary (DTRichText)

- (void)toggleBold;
- (void)toggleItalic;
- (void)toggleUnderline;

- (void)toggleHighlightWithColor:(UIColor *)color;

- (void)removeAttachment;

@end
