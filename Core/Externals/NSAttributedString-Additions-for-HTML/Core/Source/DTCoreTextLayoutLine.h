//
//  DTCoreTextLine.h
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreText/CoreText.h>

@class DTCoreTextLayoutFrame;

@interface DTCoreTextLayoutLine : NSObject 
{
	CGRect _frame;
	CTLineRef _line;
	NSAttributedString *_attributedString;
	
	CGPoint _baselineOrigin;
	
	CGFloat ascent;
	CGFloat descent;
	CGFloat leading;
	CGFloat width;
	CGFloat trailingWhitespaceWidth;
	
	NSArray *_glyphRuns;

	BOOL _didCalculateMetrics;
	NSInteger _stringLocationOffset;
}

- (id)initWithLine:(CTLineRef)line layoutFrame:(DTCoreTextLayoutFrame *)layoutFrame origin:(CGPoint)origin;

- (NSRange)stringRange;
- (NSInteger)numberOfGlyphs;
- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;
- (NSArray *)glyphRunsWithRange:(NSRange)range;
- (CGRect)frameOfGlyphsWithRange:(NSRange)range;
- (CGRect)imageBoundsInContext:(CGContextRef)context;
- (NSArray *)stringIndices;
- (CGFloat)offsetForStringIndex:(NSInteger)index;
- (NSInteger)stringIndexForPosition:(CGPoint)position;

- (CGFloat)paragraphSpacing;
- (CGFloat)lineHeight;
- (CGFloat)calculatedLeading;

- (void)drawInContext:(CGContextRef)context;

- (BOOL)correctAttachmentHeights:(CGFloat *)downShift;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, retain, readonly) NSArray *glyphRuns;

@property (nonatomic, assign) CGFloat ascent; // needs to be modifyable
@property (nonatomic, assign, readonly) CGFloat descent;
@property (nonatomic, assign, readonly) CGFloat leading;
@property (nonatomic, assign, readonly) CGFloat trailingWhitespaceWidth;

@property (nonatomic, assign) CGPoint baselineOrigin;

@end
