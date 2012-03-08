//
//  NSAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

@class DTCSSListStyle;

@interface NSAttributedString (DTRichText)

// the attributes that are used if typing starts at this position
- (NSDictionary *)typingAttributesForRange:(NSRange)range;

// create an attributed string with text attachment
+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize;

// create attributed string with hyperlink
+ (NSAttributedString *)attributedStringWithURL:(NSURL *)url;

// for debugging
- (NSString *)dumpString;

@end
