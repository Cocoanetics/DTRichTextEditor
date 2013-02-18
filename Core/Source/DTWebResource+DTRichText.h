//
//  DTWebArchive+DTRichText.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 12/1/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTWebResource.h"

/**
 Methods for extenting DTWebResource for use with DTRichTextEditor.
 */
@interface DTWebResource (DTRichText)

/**
 Convenience method to retrieve the image represented by the receiver.
 @returns The image or `nil` if the receiver is not an image.
 */
- (UIImage *)image;

@end
