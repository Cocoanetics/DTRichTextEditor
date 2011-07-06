//
//  DTRichTextRange.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTTextPosition.h"

@interface DTTextRange : UITextRange <NSCopying>
{
	DTTextPosition *_start;
	DTTextPosition *_end;
}


+ (DTTextRange *)textRangeFromStart:(DTTextPosition *)start toEnd:(DTTextPosition *)end;
//+ (DTTextRange *)textRangeFromStartLocation:(NSInteger)start toEndLocation:(NSInteger)end;

+ (DTTextRange *)emptyRangeAtPosition:(DTTextPosition *)position offset:(NSInteger)offset;

- (id)initWithStart:(DTTextPosition *)start end:(DTTextPosition *)end;
- (id)initWithNSRange:(NSRange)range;

- (NSRange)NSRangeValue;
- (NSUInteger)length;

- (DTTextPosition *)start;
- (DTTextPosition *)end;


@end
