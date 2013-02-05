//
//  DTTiledLayerWithoutFade.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 8/24/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import "DTTiledLayerWithoutFade.h"

@implementation DTTiledLayerWithoutFade

+ (CFTimeInterval)fadeDuration
{
	return 0;
}


- (void)setNeedsDisplay
{
    NSLog(@"layout setneedsdisplay");
    [super setNeedsDisplay];
}

- (void)setNeedsDisplayInRect:(CGRect)rect
{
	NSLog(@"layer set needs display: %@", NSStringFromCGRect(rect));
	[super setNeedsDisplayInRect:rect];
}

@end
