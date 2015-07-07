//
//  NSAttributedString+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCSSListStyle;

/**
 Methods to extend `NSAttributedString` for use by DTRichTextEditor
 */
@interface NSAttributedString (DTRichText)

/**
 Retrieves the attributes that are used if typing starts at this position.
 @param range The string range to query
 @returns A dictionary of CoreText attributes suitable for creating an attributed string to insert
 */
- (NSDictionary *)typingAttributesForRange:(NSRange)range;

/**
 Create an attributed string with text attachment for an image.
 
 The maximum display size can be limited to a reasonable size.
 @param image The image to embed in the attributed string
 @param maxDisplaySize The maximum display size to allow for the embedded image
 */
+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image maxDisplaySize:(CGSize)maxDisplaySize;

/**
 Creates an attributed string with a hyperlink.
 @param URL The `NSURL` for the hyperlink
 */
+ (NSAttributedString *)attributedStringWithURL:(NSURL *)URL;

@end
