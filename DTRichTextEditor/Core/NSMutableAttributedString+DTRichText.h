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

// the attributes that are used if typing starts at this position
- (NSDictionary *)typingAttributesForRange:(NSRange)range;

// convenience method to insert an attachment
- (void)replaceRange:(NSRange)range withAttachment:(DTTextAttachment *)attachment inParagraph:(BOOL)inParagraph;

// convenience methods to toggline simple styles
- (void)toggleBoldInRange:(NSRange)range;
- (void)toggleItalicInRange:(NSRange)range;
- (void)toggleUnderlineInRange:(NSRange)range;

@end
