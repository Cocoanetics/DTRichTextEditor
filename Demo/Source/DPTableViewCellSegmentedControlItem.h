//
//  DPTableViewCellSegmentedControlItem.h
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 20/05/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPTableViewCellSegmentedControlItem : NSObject

@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIImage *iconHighlighted;

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

+ (instancetype)itemWithImages:(NSArray *)images;

@end
