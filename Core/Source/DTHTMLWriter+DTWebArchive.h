//
//  DTHTMLWriter+DTWebArchive.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 23.12.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTHTMLWriter.h>

@class DTWebArchive;

/**
 Creating web archive from a DTHTMLWriter. 
 */

@interface DTHTMLWriter (DTWebArchive)

/**
 Creates a web archive from the writer's attributed string
 */
- (DTWebArchive *)webArchive;

@end
