//
//  DTCoreTextFontDescriptor.m
//  CoreTextExtensions
//
//  Created by Oliver Drobnik on 1/26/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "DTCoreTextFontDescriptor.h"

static NSCache *_fontCache = nil;
static NSMutableDictionary *_fontOverrides = nil;

static dispatch_semaphore_t fontLock;

@interface DTCoreTextFontDescriptor ()

// generated fonts are cached
+ (NSCache *)fontCache;

@end

@implementation DTCoreTextFontDescriptor
{
	NSString *fontFamily;
	NSString *fontName;
	
	CGFloat _pointSize;
	
	CTFontSymbolicTraits _stylisticTraits;
	CTFontStylisticClass _stylisticClass;
    
	BOOL smallCapsFeature;
}

+ (void)initialize
{
	if(self == [DTCoreTextFontDescriptor class]) {
		fontLock = dispatch_semaphore_create(1);
	}
}

+ (NSCache *)fontCache
{
	if (!_fontCache)
	{
		_fontCache = [[NSCache alloc] init];
	}

	return _fontCache;
}

+ (NSMutableDictionary *)fontOverrides
{
	if (!_fontOverrides)
	{
		_fontOverrides = [[NSMutableDictionary alloc] init];
		
		
		// see if there is an overrides table to preload
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"DTCoreTextFontOverrides" ofType:@"plist"];
		NSArray *fileArray = [NSArray arrayWithContentsOfFile:path];
		
		for (NSDictionary *oneOverride in fileArray)
		{
			NSString *fontFamily = [oneOverride objectForKey:@"FontFamily"];
			NSString *overrideFontName = [oneOverride objectForKey:@"OverrideFontName"];
			BOOL bold = [[oneOverride objectForKey:@"Bold"] boolValue];
			BOOL italic = [[oneOverride objectForKey:@"Italic"] boolValue];
			BOOL smallcaps = [[oneOverride objectForKey:@"SmallCaps"] boolValue];
			
			if (smallcaps)
			{
				[DTCoreTextFontDescriptor setSmallCapsFontName:overrideFontName forFontFamily:fontFamily bold:bold italic:italic];
			}
			else
			{
				[DTCoreTextFontDescriptor setOverrideFontName:overrideFontName forFontFamily:fontFamily bold:bold italic:italic];
			}
		}
	}
	
	return _fontOverrides;
}

+ (void)setSmallCapsFontName:(NSString *)fontName forFontFamily:(NSString *)fontFamily bold:(BOOL)bold italic:(BOOL)italic
{
	NSString *key = [NSString stringWithFormat:@"%@-%d-%d-smallcaps", fontFamily, bold, italic];
	
	[[DTCoreTextFontDescriptor fontOverrides] setObject:fontName forKey:key];
}

+ (NSString *)smallCapsFontNameforFontFamily:(NSString *)fontFamily bold:(BOOL)bold italic:(BOOL)italic
{
	NSString *key = [NSString stringWithFormat:@"%@-%d-%d-smallcaps", fontFamily, bold, italic];
	
	return [[DTCoreTextFontDescriptor fontOverrides] objectForKey:key];
}

+ (void)setOverrideFontName:(NSString *)fontName forFontFamily:(NSString *)fontFamily bold:(BOOL)bold italic:(BOOL)italic
{
	NSString *key = [NSString stringWithFormat:@"%@-%d-%d-override", fontFamily, bold, italic];
	
	[[DTCoreTextFontDescriptor fontOverrides] setObject:fontName forKey:key];
}

+ (NSString *)overrideFontNameforFontFamily:(NSString *)fontFamily bold:(BOOL)bold italic:(BOOL)italic
{
	NSString *key = [NSString stringWithFormat:@"%@-%d-%d-override", fontFamily, bold, italic];
	
	return [[DTCoreTextFontDescriptor fontOverrides] objectForKey:key];
}

+ (DTCoreTextFontDescriptor *)fontDescriptorWithFontAttributes:(NSDictionary *)attributes
{
	return [[DTCoreTextFontDescriptor alloc] initWithFontAttributes:attributes];
}

+ (DTCoreTextFontDescriptor *)fontDescriptorForCTFont:(CTFontRef)ctFont
{
	return [[DTCoreTextFontDescriptor alloc] initWithCTFont:ctFont];
}

- (id)initWithFontAttributes:(NSDictionary *)attributes
{
	self = [super init];
	if (self)
	{
		[self setFontAttributes:attributes];
	}
	
	return self;
}

- (id)initWithCTFontDescriptor:(CTFontDescriptorRef)ctFontDescriptor
{
	self = [super init];
	if (self)
	{
		CFDictionaryRef dict = CTFontDescriptorCopyAttributes(ctFontDescriptor);
		
		CFDictionaryRef traitsDict = CTFontDescriptorCopyAttribute(ctFontDescriptor, kCTFontTraitsAttribute);
		CTFontSymbolicTraits traitsValue = [[(__bridge NSDictionary *)traitsDict objectForKey:(id)kCTFontSymbolicTrait] unsignedIntValue];
		CFRelease(traitsDict);
		
		self.symbolicTraits = traitsValue;
		
		[self setFontAttributes:CFBridgingRelease(dict)];
		//CFRelease(dict);
		
		// also get family name
		
		CFStringRef familyName = CTFontDescriptorCopyAttribute(ctFontDescriptor, kCTFontFamilyNameAttribute);
		self.fontFamily = CFBridgingRelease(familyName);
		//CFRelease(familyName);
	}
	
	return self;
}

- (id)initWithCTFont:(CTFontRef)ctFont
{
	self = [super init];
	if (self)
	{
		CTFontDescriptorRef fd = CTFontCopyFontDescriptor(ctFont);
		CFDictionaryRef dict = CTFontDescriptorCopyAttributes(fd);
		
		CFDictionaryRef traitsDict = CTFontDescriptorCopyAttribute(fd, kCTFontTraitsAttribute);
		CTFontSymbolicTraits traitsValue = [[(__bridge NSDictionary *)traitsDict objectForKey:(id)kCTFontSymbolicTrait] unsignedIntValue];
		CFRelease(traitsDict);
		CFRelease(fd);
		
		self.symbolicTraits = traitsValue;
		
		[self setFontAttributes:CFBridgingRelease(dict)];
		//CFRelease(dict);
		
		// also get the family while we're at it
		CFStringRef cfStr = CTFontCopyFamilyName(ctFont);
		
		if (cfStr)
		{
			self.fontFamily = CFBridgingRelease(cfStr);
			//CFRelease(cfStr);
		}
	}
	
	return self;
}



- (NSString *)description
{
	NSMutableString *string = [NSMutableString string];
	
	[string appendFormat:@"<%@ ", [self class]];
	
	
	if (self.fontName)
	{
		[string appendFormat:@"name:\'%@\' ", self.fontName];
	}
	
	if (fontFamily)
	{
		[string appendFormat:@"family:\'%@\' ", fontFamily];
	}
	
	NSMutableArray *tmpTraits = [NSMutableArray array];
	
	if (_stylisticTraits & kCTFontBoldTrait)
	{
		[tmpTraits addObject:@"bold"];
	}
	
	if (_stylisticTraits & kCTFontItalicTrait)
	{
		[tmpTraits addObject:@"italic"];
	}
	
	if (_stylisticTraits & kCTFontMonoSpaceTrait)
	{
		[tmpTraits addObject:@"monospace"];
	}
	
	if (_stylisticTraits & kCTFontCondensedTrait)
	{
		[tmpTraits addObject:@"condensed"];
	}
	
	if (_stylisticTraits & kCTFontExpandedTrait)
	{
		[tmpTraits addObject:@"expanded"];
	}
	
	if (_stylisticTraits & kCTFontVerticalTrait)
	{
		[tmpTraits addObject:@"vertical"];
	}
	
	if (_stylisticTraits & kCTFontUIOptimizedTrait)
	{
		[tmpTraits addObject:@"UI optimized"];
	}
	
	
	if ([tmpTraits count])
	{
		[string appendString:@"attributes:"];
		[string appendString:[tmpTraits componentsJoinedByString:@", "]];
	}
	
	[string appendString:@">"];
	
	return string;
}

- (CTFontSymbolicTraits)symbolicTraits
{
	CTFontSymbolicTraits retValue = _stylisticTraits;
	
	// bundle in class
	retValue |= _stylisticClass;
	
	return retValue;
}

- (NSDictionary *)fontAttributes
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *traitsDict = [NSMutableDictionary dictionary];
	
	CTFontSymbolicTraits theSymbolicTraits = _stylisticTraits | _stylisticClass;
	
	if (theSymbolicTraits)
	{
		[traitsDict setObject:[NSNumber numberWithUnsignedInt:theSymbolicTraits] forKey:(id)kCTFontSymbolicTrait];
	}
	
	if ([traitsDict count])
	{
		[tmpDict setObject:traitsDict forKey:(id)kCTFontTraitsAttribute];
	}
	
	if (fontFamily)
	{
		[tmpDict setObject:fontFamily forKey:(id)kCTFontFamilyNameAttribute];
	}
	
	if (fontName)
	{
		[tmpDict setObject:fontName forKey:(id)kCTFontNameAttribute];
	}
	
	// we need size because that's what makes a font unique, for searching it's ignored anyway
	[tmpDict setObject:[NSNumber numberWithFloat:_pointSize] forKey:(id)kCTFontSizeAttribute];
	
	
	if (smallCapsFeature)
	{
		NSNumber *typeNum = [NSNumber numberWithInteger:3];
		NSNumber *selNum = [NSNumber numberWithInteger:3];
		
		NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:selNum, (id)kCTFontFeatureSelectorIdentifierKey,
														 typeNum, (id)kCTFontFeatureTypeIdentifierKey, nil];
		
		NSArray *featureSettings = [NSArray arrayWithObject:setting];
		
		[tmpDict setObject:featureSettings forKey:(id)kCTFontFeatureSettingsAttribute];
	}
	
	//return [NSDictionary dictionaryWithDictionary:tmpDict];
	
	// converting to non-mutable costs 42% of entire method
	return tmpDict;
}

- (BOOL)supportsNativeSmallCaps
{
	if ([DTCoreTextFontDescriptor smallCapsFontNameforFontFamily:fontFamily bold:self.boldTrait italic:self.italicTrait])
	{
		return YES;
	}
	
	CTFontRef tmpFont = [self newMatchingFont];
	
	BOOL smallCapsSupported = NO;
	
	// check if this font supports small caps
	CFArrayRef fontFeatures = CTFontCopyFeatures(tmpFont);
	
	if (fontFeatures)
	{
		for (NSDictionary *oneFeature in (__bridge NSArray *)fontFeatures)
		{
			NSInteger featureTypeIdentifier = [[oneFeature objectForKey:(id)kCTFontFeatureTypeIdentifierKey] integerValue];
			
			if (featureTypeIdentifier == 3) // Letter Case
			{
				NSArray *featureSelectors = [oneFeature objectForKey:(id)kCTFontFeatureTypeSelectorsKey];
				
				for (NSDictionary *oneFeatureSelector in featureSelectors)
				{
					NSInteger featureSelectorIdentifier = [[oneFeatureSelector objectForKey:(id)kCTFontFeatureSelectorIdentifierKey] integerValue];
					
					if (featureSelectorIdentifier == 3) // Small Caps
					{
						// hooray, small caps supported!
						smallCapsSupported = YES;
						
						break;
					}
				}
				
				break;
			}
		}
		
		CFRelease(fontFeatures);
	}
	
	CFRelease(tmpFont);
	
	return smallCapsSupported;
}

#pragma mark Finding Font

- (CTFontRef)newMatchingFont
{
	dispatch_semaphore_wait(fontLock, DISPATCH_TIME_FOREVER);

	NSDictionary *attributes = [self fontAttributes];
	
	NSCache *fontCache = [DTCoreTextFontDescriptor fontCache];
	NSString *cacheKey = [attributes description];
	
	CTFontRef cachedFont = (__bridge CTFontRef)[fontCache objectForKey:cacheKey];
	
	if (cachedFont)
	{
		CFRetain(cachedFont);
		dispatch_semaphore_signal(fontLock);
		return cachedFont;
	}
	
	CTFontDescriptorRef fontDesc = NULL;
	
	CTFontRef matchingFont;
	
	NSString *usedName = fontName;
	
	// override fontName if a small caps or regular override is registered
	if (fontFamily)
	{
		NSString *overrideFontName = nil;
		if (smallCapsFeature)
		{
			overrideFontName = [DTCoreTextFontDescriptor smallCapsFontNameforFontFamily:fontFamily bold:self.boldTrait italic:self.italicTrait];
		}
		else
		{
			overrideFontName = [DTCoreTextFontDescriptor overrideFontNameforFontFamily:fontFamily bold:self.boldTrait italic:self.italicTrait];
		}
    
		if (overrideFontName)
		{
			usedName = overrideFontName;
		}
	}
	
	if (usedName)
	{
		matchingFont = CTFontCreateWithName((__bridge CFStringRef)usedName, _pointSize, NULL);
	}
	else
	{
		fontDesc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
		
		if (fontFamily)
		{
			// fast font creation
			matchingFont = CTFontCreateWithFontDescriptor(fontDesc, _pointSize, NULL);
		}
		else
		{
			// without font name or family we need to do expensive search
			// otherwise we always get Helvetica
			
			NSMutableSet *set = [NSMutableSet setWithObject:(id)kCTFontTraitsAttribute];
			
			if (fontFamily)
			{
				[set addObject:(id)kCTFontFamilyNameAttribute];
			}
			
			if (smallCapsFeature)
			{
				[set addObject:(id)kCTFontFeaturesAttribute];
			}
			
			CTFontDescriptorRef matchingDesc = CTFontDescriptorCreateMatchingFontDescriptor(fontDesc, (__bridge CFSetRef)set);
			
			if (matchingDesc)
			{
				matchingFont = CTFontCreateWithFontDescriptor(matchingDesc, _pointSize, NULL);
				CFRelease(matchingDesc);
			}
			else 
			{
				matchingFont = nil;
			}
		}
		CFRelease(fontDesc);
		
	}
	
	if (matchingFont)
	{
		// cache it
		[fontCache setObject:(__bridge id)(matchingFont) forKey:cacheKey];	// if you CFBridgeRelease you get a crash
	}
	dispatch_semaphore_signal(fontLock);
	return matchingFont;
}

// two font descriptors are equal if their attributes has identical hash codes
- (NSUInteger)hash
{
	NSUInteger calcHash = 7;
	
	calcHash = calcHash*31 + _pointSize;
	calcHash = calcHash*31 + (_stylisticClass | _stylisticTraits);
	calcHash = calcHash*31 + [fontName hash];
	calcHash = calcHash*31 + [fontFamily hash];
	
	return calcHash;
}

- (BOOL)isEqual:(id)object
{
	return (([object isKindOfClass:[DTCoreTextFontDescriptor class]]) && ([self hash] == [object hash]));
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.fontName forKey:@"FontName"];
	[encoder encodeObject:self.fontFamily forKey:@"FontFamily"];
	[encoder encodeBool:self.boldTrait forKey:@"BoldTrait"];
	[encoder encodeBool:self.italicTrait forKey:@"ItalicTrait"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	if (self)
	{
		self.fontName = [decoder decodeObjectForKey:@"FontName"];
		self.fontFamily = [decoder decodeObjectForKey:@"FontFamily"];
		self.boldTrait = [decoder decodeBoolForKey:@"BoldTrait"];
		self.italicTrait = [decoder decodeBoolForKey:@"ItalicTrait"];
	}
	
	return self;
}


#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
	DTCoreTextFontDescriptor *newDesc = [[DTCoreTextFontDescriptor allocWithZone:zone] initWithFontAttributes:[self fontAttributes]];
	newDesc.pointSize = self.pointSize;
	if (_stylisticClass)
	{
		newDesc.stylisticClass = self.stylisticClass;
	}
	
	return newDesc;
}


#pragma mark Properties
- (void)setStylisticClass:(CTFontStylisticClass)newClass
{
	self.fontFamily = nil;
	
	_stylisticClass = newClass;
}


- (void)setFontAttributes:(NSDictionary *)attributes
{
	if (!attributes) 
	{
		self.fontFamily = nil;
		self.fontName = nil;
		self.pointSize = 12;
		
		_stylisticTraits = 0;
		_stylisticClass = 0;
	}
	
	NSDictionary *traitsDict = [attributes objectForKey:(id)kCTFontTraitsAttribute];
	
	if (traitsDict)
	{
		CTFontSymbolicTraits traitsValue = [[traitsDict objectForKey:(id)kCTFontSymbolicTrait ] unsignedIntValue];
		self.symbolicTraits = traitsValue;
	}
	
	NSNumber *pointNum = [attributes objectForKey:(id)kCTFontSizeAttribute];
	if (pointNum)
	{
		_pointSize = [pointNum floatValue];
	}
	
	NSString *family = [attributes objectForKey:(id)kCTFontFamilyNameAttribute];
	
	if (family)
	{
		self.fontFamily = family;
	}
	
	NSString *name = [attributes objectForKey:(id)kCTFontNameAttribute];
	
	if (name)
	{
		self.fontName = name;
	}
}

- (void)setSymbolicTraits:(CTFontSymbolicTraits)theSymbolicTraits
{
	_stylisticTraits = theSymbolicTraits;
	
	// stylistic class is bundled in the traits
	_stylisticClass = theSymbolicTraits & kCTFontClassMaskTrait;   
}


// a representation of this font in CSS style
- (NSString *)cssStyleRepresentation
{
	NSMutableString *retString = [NSMutableString string];
	
	if (fontFamily)
	{
		[retString appendFormat:@"font-family:'%@';", fontFamily];
	}
	
	[retString appendFormat:@"font-size:%.0fpx;", _pointSize];
	
	if (self.italicTrait)
	{
		[retString appendString:@"font-style:italic;"];
	}
	
	if (self.boldTrait)
	{
		[retString appendString:@"font-weight:bold;"];
	}

	// return nil if no content
	if ([retString length])
	{
		return retString;
	}
	else
	{
		return nil;
	}
}

- (void)setBoldTrait:(BOOL)boldTrait
{
	if (boldTrait)
	{
		_stylisticTraits |= kCTFontBoldTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontBoldTrait;
	}
}

- (BOOL)boldTrait
{
	return (_stylisticTraits & kCTFontBoldTrait)!=0;
}

- (void)setItalicTrait:(BOOL)italicTrait
{
	if (italicTrait)
	{
		_stylisticTraits |= kCTFontItalicTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontItalicTrait;
	}
}

- (BOOL)italicTrait
{
	return (_stylisticTraits & kCTFontItalicTrait)!=0;
}

- (void)setExpandedTrait:(BOOL)expandedTrait
{
	if (expandedTrait)
	{
		_stylisticTraits |= kCTFontExpandedTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontExpandedTrait;
	}
}

- (BOOL)expandedTrait
{
	return (_stylisticTraits & kCTFontExpandedTrait)!=0;
}

- (void)setCondensedTrait:(BOOL)condensedTrait
{
	if (condensedTrait)
	{
		_stylisticTraits |= kCTFontCondensedTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontCondensedTrait;
	}
}

- (BOOL)condensedTrait
{
	return (_stylisticTraits & kCTFontCondensedTrait)!=0;
}

- (void)setMonospaceTrait:(BOOL)monospaceTrait
{
	if (monospaceTrait)
	{
		_stylisticTraits |= kCTFontMonoSpaceTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontMonoSpaceTrait;
	}
}

- (BOOL)monospaceTrait
{
	return (_stylisticTraits & kCTFontMonoSpaceTrait)!=0;
}

- (void)setVerticalTrait:(BOOL)verticalTrait
{
	if (verticalTrait)
	{
		_stylisticTraits |= kCTFontVerticalTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontVerticalTrait;
	}
}

- (BOOL)verticalTrait
{
	return (_stylisticTraits & kCTFontVerticalTrait)!=0;
}

- (void)setUIoptimizedTrait:(BOOL)UIoptimizedTrait
{
	if (UIoptimizedTrait)
	{
		_stylisticTraits |= kCTFontUIOptimizedTrait;
	}
	else
	{
		_stylisticTraits &= ~kCTFontUIOptimizedTrait;
	}
}

- (BOOL)UIoptimizedTrait
{
	return (_stylisticTraits & kCTFontUIOptimizedTrait)!=0;
}

- (void)setPointSize:(CGFloat)pointSize
{
	_pointSize = roundf(pointSize);
}

@synthesize fontFamily;
@synthesize fontName;
@synthesize pointSize = _pointSize;

@synthesize symbolicTraits;

@synthesize stylisticClass;
@synthesize smallCapsFeature;

@end

