//
//  DTTextPosition.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DTTextPosition : UITextPosition <NSCopying>
{
	NSUInteger _location;
}

+ (DTTextPosition *)textPositionWithLocation:(NSUInteger)location;

- (id)initWithLocation:(NSUInteger)location;

- (NSComparisonResult)compare:(id)object;
- (BOOL)isEqual:(DTTextPosition *)aPosition;

- (DTTextPosition *)textPositionWithOffset:(NSInteger)offset;

@property (nonatomic, assign) NSUInteger location;

@end
