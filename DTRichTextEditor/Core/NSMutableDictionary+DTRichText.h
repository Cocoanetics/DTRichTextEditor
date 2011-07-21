//
//  NSMutableDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DTRichText)

- (BOOL)isBold;
- (BOOL)isItalic;
- (BOOL)isUnderline;

- (void)toggleBold;
- (void)toggleItalic;
- (void)toggleUnderline;

@end
