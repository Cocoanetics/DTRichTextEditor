//
//  NSDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DTRichText)

- (BOOL)isBold;
- (BOOL)isItalic;
- (BOOL)isUnderline;

- (BOOL)hasAttachment;

@end
