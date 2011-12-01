//
//  DTWebArchive.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTWebResource.h"

/** The pasteboard type for this class. */
extern NSString * WebArchivePboardType;

/** A `DTWebArchive` object represents a webpage that can be archived—for example, archived on disk or on the pasteboard. A `DTWebArchive` object contains the main resource, as well as the subresources and subframes of the main resource. The main resource can be an entire webpage, a portion of a webpage, or some other kind of data such as an image. Use this class to archive webpages, or place a portion of a webpage on the pasteboard, or to represent rich web content in any application.
 */

@interface DTWebArchive : NSObject
{
	DTWebResource *_mainResource;
	NSArray *_subresources;
	NSArray *_subframeArchives;
}

/**---------------------------------------------------------------------------------------
 * @name Initializing
 * ---------------------------------------------------------------------------------------
 */

/** Initializes and returns the receiver. 
 
 Use the <data> method to get the receiver’s data.
 @param data The initial content data.
 */
- (id)initWithData:(NSData *)data;

/** Initializes the receiver with a resource and optional subresources and subframe archives.
 
This method initializes and returns the receiver.
 
 @param mainResource The main resource for the archive.
 @param subresources An array of <DTWebResource> objects or `nil` if none are specified. 
 @param subframeArchives An array of <DTWebArchive> objects used by the sub frames or `nil` if none are specified.
 */
- (id)initWithMainResource:(DTWebResource *)mainResource subresources:(NSArray *)subresources subframeArchives:(NSArray *)subframeArchives;

/**---------------------------------------------------------------------------------------
 * @name Getting Attributes
 * ---------------------------------------------------------------------------------------
 */

/** Returns the receiver’s main resource. */
- (DTWebResource *)mainResource;

/** Returns the receiver’s sub resources, or `nil` if there are none. */
- (NSArray *)subresources;

/** Returns archives representing the receiver’s sub frame archives or `nil` if there are none. */
- (NSArray *)subframeArchives;

/** Returns the data representation of the receiver.
 
 The data returned can be used to save the web archive to a file, to put it on the pasteboard using the `WebArchivePboardType` type, or used to initialize another web archive using the <initWithData:> method.
 */
- (NSData *)data;

@end