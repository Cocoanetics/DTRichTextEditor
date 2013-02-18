//
//  UIPasteboard+DTWebArchive.h
//  DTWebArchive
//
//  Created by Oliver Drobnik on 9/2/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTWebArchive;

/**
 Convenient addition to `UIPasteboard` to get a web archive
 */
@interface UIPasteboard (DTWebArchive)

/**
 Retrieves a web archive contained in the receiver, or `nil` if there is none
 */
@property(nonatomic,copy) DTWebArchive *webArchive;

@end
