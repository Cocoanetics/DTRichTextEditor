//
//  DTCoreTextLayouter.m
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "DTCoreTextLayouter.h"

@interface DTCoreTextLayouter ()

@property (nonatomic, strong) NSMutableArray *frames;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_semaphore_t selfLock;  // GCD objects use ARC
#else
@property (nonatomic, assign) dispatch_semaphore_t selfLock;  // GCD objects don't use ARC
#endif

- (CTFramesetterRef)framesetter;
- (void)discardFramesetter;

@end

#define SYNCHRONIZE_START(obj) dispatch_semaphore_wait(selfLock, DISPATCH_TIME_FOREVER);
#define SYNCHRONIZE_END(obj) dispatch_semaphore_signal(selfLock);

@implementation DTCoreTextLayouter
{
	CTFramesetterRef _framesetter;
	
	NSAttributedString *_attributedString;
	
	NSMutableArray *frames;
	
	BOOL _shouldCacheLayoutFrames;
	NSCache *_layoutFrameCache;
}
@synthesize selfLock;

- (id)initWithAttributedString:(NSAttributedString *)attributedString
{
	if ((self = [super init]))
	{
		if (!attributedString)
		{
			return nil;
		}
		
		selfLock = dispatch_semaphore_create(1);
		self.attributedString = attributedString;
	}
	
	return self;
}

- (void)dealloc
{
	SYNCHRONIZE_START(self)	// just to be sure
	[self discardFramesetter];
	SYNCHRONIZE_END(self)

#if !OS_OBJECT_USE_OBJC
	dispatch_release(selfLock);
#endif
}

- (NSString *)description
{
	return [self.frames description];
}

- (NSInteger)numberOfFrames
{
	return [self.frames count];
}

- (CGSize)suggestedFrameSizeToFitEntireStringConstraintedToWidth:(CGFloat)width
{
	// Note: this returns an unreliable measure prior to 4.2 for very long documents
	CGSize neededSize = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter, CFRangeMake(0, 0), NULL, 
																	 CGSizeMake(width, CGFLOAT_MAX),
																	 NULL);

	
	
	
	// round up because generally we don't want non-integer view sizes
	neededSize.width = ceilf(neededSize.width);
	neededSize.height = ceilf(neededSize.height);
	
	return neededSize;
}


// a temporary frame
- (DTCoreTextLayoutFrame *)layoutFrameWithRect:(CGRect)frame range:(NSRange)range
{
	DTCoreTextLayoutFrame *newFrame = nil;
	NSString *cacheKey = nil;
	
	// need to have a non zero
	if (!(frame.size.width > 0 && frame.size.height > 0))
	{
		return nil;
	}
	
	if (_shouldCacheLayoutFrames)
	{
		cacheKey = [NSString stringWithFormat:@"%ud-%@-%@", [_attributedString hash], NSStringFromCGRect(frame), NSStringFromRange(range)];
		
		DTCoreTextLayoutFrame *cachedLayoutFrame = [_layoutFrameCache objectForKey:cacheKey];
		
		if (cachedLayoutFrame)
		{
			return cachedLayoutFrame;
		}
	}

	@autoreleasepool {
		newFrame = [[DTCoreTextLayoutFrame alloc] initWithFrame:frame layouter:self range:range];
	};
	
	if (newFrame && _shouldCacheLayoutFrames)
	{
		[_layoutFrameCache setObject:newFrame forKey:cacheKey];
	}
	
	return newFrame;
}

// reusable frame
- (void)addTextFrameWithFrame:(CGRect)frame
{
	DTCoreTextLayoutFrame *newFrame = [self layoutFrameWithRect:frame range:NSMakeRange(0, 0)];
	[self.frames addObject:newFrame];
}

- (DTCoreTextLayoutFrame *)layoutFrameAtIndex:(NSInteger)index
{
	return [self.frames objectAtIndex:index];
	
}

#pragma mark Properties
- (CTFramesetterRef)framesetter
{
	if (!_framesetter) // Race condition, could be null now but set when we get into the SYNCHRONIZE block - so do the test twice
	{
		SYNCHRONIZE_START(self)
		{
			if (!_framesetter)
			{
				_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
			}
		}
		SYNCHRONIZE_END(self)
	}
	return _framesetter;
}


- (void)discardFramesetter
{
	{
		// framesetter needs to go
		if (_framesetter)
		{
			CFRelease(_framesetter);
			_framesetter = NULL;
		}
	}
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
	SYNCHRONIZE_START(self)
	{
		if (_attributedString != attributedString)
		{
			_attributedString = attributedString;
			
			[self discardFramesetter];
			
			// clear the cache
			_layoutFrameCache = nil;
		}
	}
	SYNCHRONIZE_END(self)
}

- (NSAttributedString *)attributedString
{
	return _attributedString;
}

- (NSMutableArray *)frames
{
	if (!frames)
	{
		frames = [[NSMutableArray alloc] init];
	}
	
	return frames;
}

- (void)setShouldCacheLayoutFrames:(BOOL)shouldCacheLayoutFrames
{
	if (_shouldCacheLayoutFrames != shouldCacheLayoutFrames)
	{
		_shouldCacheLayoutFrames = shouldCacheLayoutFrames;
		
		if (shouldCacheLayoutFrames)
		{
			_layoutFrameCache = [[NSCache alloc] init];
		}
		else
		{
			_layoutFrameCache = nil;
		}
	}
}



@synthesize attributedString = _attributedString;
@synthesize frames = _frames;
@synthesize framesetter = _framesetter;
@synthesize shouldCacheLayoutFrames = _shouldCacheLayoutFrames;

@end
