//
//  NSMutableAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTTextAttachment;

@interface NSMutableAttributedString (DTRichText)


- (NSDictionary *)typingAttributesForRange:(NSRange)range;

- (void)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment;

@end
