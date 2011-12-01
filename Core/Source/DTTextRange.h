//
//  DTRichTextRange.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTTextPosition.h"

@interface DTTextRange : UITextRange <NSCopying>
{
	DTTextPosition *_start;
	DTTextPosition *_end;
}


+ (DTTextRange *)textRangeFromStart:(UITextPosition *)start toEnd:(UITextPosition *)end;
//+ (DTTextRange *)textRangeFromStartLocation:(NSInteger)start toEndLocation:(NSInteger)end;

+ (DTTextRange *)emptyRangeAtPosition:(UITextPosition *)position offset:(NSInteger)offset;

- (id)initWithStart:(UITextPosition *)start end:(UITextPosition *)end;
- (id)initWithNSRange:(NSRange)range;

- (NSRange)NSRangeValue;
- (NSUInteger)length;

//- (DTTextPosition *)start;
//- (DTTextPosition *)end;


@end
