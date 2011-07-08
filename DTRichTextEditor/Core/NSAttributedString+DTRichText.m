//
//  NSAttributedString+DTRichText.m
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSAttributedString+DTRichText.h"

#import "DTHTMLElement.h"
#import "DTTextAttachment.h"
#import "DTCoreTextParagraphStyle.h"

@implementation NSAttributedString (DTRichText)

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image
{
	DTTextAttachment *attachment = [[[DTTextAttachment alloc] init] autorelease];
	attachment.contents = (id)image;
	attachment.displaySize = image.size;
	attachment.originalSize = image.size;
	attachment.contentType = DTTextAttachmentTypeImage;
	
	DTHTMLElement *element = [[[DTHTMLElement alloc] init] autorelease];
	element.textAttachment = attachment;
	
	
	
	return [element attributedString];
}

@end
