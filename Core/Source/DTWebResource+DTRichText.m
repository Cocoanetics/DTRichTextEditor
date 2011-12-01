//
//  DTWebResouce+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 12/1/11.
//  Copyright (c) 2011 Cocoanetics. All rights reserved.
//

#import "DTWebResource+DTRichText.h"

@implementation DTWebResource (DTRichText)

- (UIImage *)image
{
	if (![self.MIMEType hasPrefix:@"image"])
	{
		return nil;
	}
	
	return [UIImage imageWithData:_data];
}

@end
