//
//  DPTableViewCellSegmentedControlItem.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 20/05/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DPTableViewCellSegmentedControlItem.h"

@implementation DPTableViewCellSegmentedControlItem

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super init];
    if(self) {
        self.icon = image;
        self.iconHighlighted = highlightedImage;
    }
    return self;
}

- (UIImage *)iconHighlighted
{
    return _iconHighlighted ? _iconHighlighted : _icon;
}

+ (instancetype)itemWithImages:(NSArray *)images
{
    if(images.count == 0)
        return nil;
    
    DPTableViewCellSegmentedControlItem *item = [[DPTableViewCellSegmentedControlItem alloc] init];
    item.icon = images[0];
    item.iconHighlighted = images.count > 1 ? images[1] : images[0];
    return item;
}

@end
