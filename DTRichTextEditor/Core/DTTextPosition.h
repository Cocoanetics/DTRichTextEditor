//
//  DTTextPosition.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DTTextPosition : UITextPosition <NSCopying>
{
	NSInteger _location;
}

+ (DTTextPosition *)textPositionWithLocation:(NSInteger)location;

- (id)initWithLocation:(NSInteger)location;

- (NSComparisonResult)compare:(id)object;
- (BOOL)isEqual:(DTTextPosition *)aPosition;

- (DTTextPosition *)textPositionWithOffset:(NSInteger)offset;

@property (nonatomic, assign) NSInteger location;

@end
