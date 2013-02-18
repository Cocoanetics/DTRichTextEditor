//
//  NSAttributedString+DTWebArchive.h
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 9/6/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

@class DTWebArchive;

/**
 Convenience methods to translate between `NSAttributedString` and DTWebArchive
 */
@interface NSAttributedString (DTWebArchive)

/**
 Creates an attributed string from a web archive.
 @param webArchive The web archive
 @param options The DTAttributedStringBuilder options to use for parsing
 @param dict The resulting document attributes
 @note The documentAttributes parameter is unused at present.
 */
- (id)initWithWebArchive:(DTWebArchive *)webArchive options:(NSDictionary *)options documentAttributes:(NSDictionary **)dict;


/**
 Create a web archive from the receiver
 @returns A Web archive representing the attributed string as HTML plus linked resources
 */
- (DTWebArchive *)webArchive;

@end
