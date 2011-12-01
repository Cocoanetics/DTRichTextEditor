//
//  DTWebResource.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//


extern NSString * WebResourceDataKey;
extern NSString * WebResourceFrameNameKey;
extern NSString * WebResourceMIMETypeKey;
extern NSString * WebResourceURLKey;
extern NSString * WebResourceTextEncodingNameKey;
extern NSString * WebResourceResponseKey;

/** A `DTWebResource` object represents a downloaded URL. It encapsulates the data of the download as well as other resource properties such as the URL, MIME type, and frame name.
 
 Use the <initWithData:URL:MIMEType:textEncodingName:frameName:> method to initialize a newly created `DTWebResource` object. Use the other methods in this class to get the properties of a `DTWebResource` object.
 */
@interface DTWebResource : NSObject <NSKeyedUnarchiverDelegate>
{
	NSData *_data;
	NSString *_frameName;
	NSString *_MIMEType;
	NSURL *_URL;
	NSString *_textEncodingName;
}

/**---------------------------------------------------------------------------------------
 * @name Initializing
 * ---------------------------------------------------------------------------------------
 */

/** Initializes and returns a web resource instance.
 
 @param data The download data.
 @param URL The download URL.
 @param MIMEType The MIME type of the data.
 @param textEncodingName The IANA encoding name (for example, “utf-8” or “utf-16”). This parameter may be `nil`.
 @param frameName The name of the frame. Use this parameter if the resource represents the contents of an entire HTML frame; otherwise pass `nil`.
 @return An initialized web resource.
 */
- (id)initWithData:(NSData *)data URL:(NSURL *)URL MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName frameName:(NSString *)frameName;

//- (UIImage *)image;

/**---------------------------------------------------------------------------------------
 * @name Getting Attributes
 * ---------------------------------------------------------------------------------------
 */

/** Returns the receiver’s data.
 
 @return The download data.
 */
- (NSData *)data;

/** Returns the receiver’s frame name.
 
@return The name of the frame. If the receiver does not represent the contents of an entire HTML frame, this method returns `nil`.
 */
- (NSString *)frameName;

/** Returns the receiver’s MIME type.
 
 @return The MIME type of the data.
 */
- (NSString *)MIMEType;

/** Returns the receiver’s URL.
 
 @return The download URL.
 */
- (NSURL *)URL;

/** Returns the receiver’s text encoding name.
 
 @return The IANA encoding name (for example, “utf-8” or “utf-16”), or `nil` if the name does not exist.
 */
- (NSString *)textEncodingName;

@end


/** Private interface to work with NSDictionary */
@interface DTWebResource (Dictionary)

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
