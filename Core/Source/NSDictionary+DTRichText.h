//
//  NSDictionary+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//


/**
 Convenience methods for editors dealing with Core Text attribute dictionaries.
 */
@interface NSDictionary (DTRichText)

/**
 Whether the font in the receiver's attributes is bold.
 @returns `YES` if the text has a bold trait
 */
- (BOOL)isBold;

/**
 Whether the font in the receiver's attributes is italic.
 @returns `YES` if the text has an italic trait
 */
- (BOOL)isItalic;

/**
 Whether the receiver's attributes contains underlining.
 @returns `YES` if the text is underlined
 */
- (BOOL)isUnderline;

/**
 Whether the receiver's attributes contain a DTTextAttachment
 @returns `YES` if ther is an attachment
 */
- (BOOL)hasAttachment;

@end
