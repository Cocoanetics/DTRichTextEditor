//
//  DTRichTextRange.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 1/23/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTTextRange.h"
#import "DTTextPosition.h"

@interface DTTextRange ()

@end


@implementation DTTextRange

//+ (DTTextRange *)textRangeFromStartLocation:(NSInteger)start toEndLocation:(NSInteger)end
//{
//	DTTextRange *range = [[[DTTextRange alloc] init] autorelease];
//	range._start = [DTTextPosition textPositionWithLocation:start];
//	range._end = [DTTextPosition textPositionWithLocation:end];
//	
//	return range;
//}

+ (DTTextRange *)textRangeFromStart:(UITextPosition *)start toEnd:(UITextPosition *)end
{
	DTTextRange *range = [[DTTextRange alloc] initWithStart:start end:end];
	
	return range;
}

+ (DTTextRange *)emptyRangeAtPosition:(UITextPosition *)position offset:(NSInteger)offset
{
	DTTextPosition *newPosition = [DTTextPosition textPositionWithLocation:[(DTTextPosition *)position location] + offset];
	
	return [DTTextRange textRangeFromStart:newPosition toEnd:newPosition];
}

- (id)initWithStart:(UITextPosition  *)start end:(UITextPosition *)end
{
	self = [super init];
	if (self)
	{
		if ([(DTTextPosition *)start compare:end] == NSOrderedDescending)
		{
			_start = [end copy];
			_end = [start copy];
		}
		else 
		{
			_start = [start copy];
			_end = [end copy];
		}
	}
	
	return self;
}

- (id)initWithNSRange:(NSRange)range
{
	self = [super init];
	if (self)
	{
		_start = [[DTTextPosition alloc] initWithLocation:range.location];
		_end = [[DTTextPosition alloc] initWithLocation:range.location + range.length];
	}
	
	return self;
}

- (BOOL)isEmpty
{
	return [_start isEqual:_end];
}

//- (UITextPosition *)start
//{
//	return _start;
//}
//
//- (UITextPosition *)end
//{
//	return _end;
//}

- (NSRange)NSRangeValue
{
	return NSMakeRange(_start.location, _end.location - _start.location);
}

- (NSUInteger)length
{
	return _end.location - _start.location;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ start:%@ end:%@>", [self class], _start, _end];
}

- (DTTextPosition *)start
{
	return (DTTextPosition *)_start;
}

- (DTTextPosition *)end
{
	return (DTTextPosition *)_end;
}

- (BOOL)isEqual:(id)object
{
	UITextRange *otherRange = (DTTextRange *)object;
	return ([_start isEqual:(id)otherRange.start] && [_end isEqual:(id)otherRange.end]);
}

#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	DTTextRange *newRange = [[DTTextRange allocWithZone:zone] initWithStart:_start end:_end];
	
	return newRange;
}

@synthesize start = _start;
@synthesize end = _end;

@end
