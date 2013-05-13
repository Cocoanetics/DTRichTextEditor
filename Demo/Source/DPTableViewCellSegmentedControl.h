//
//  DPTableViewCellSegmentedControl.h
//  ui
//
//  Created by Daniel Phillips on 07/05/2013.
//  Copyright (c) 2013 Daniel Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DPTableViewCellSegmentedControlPositionSingle = 1,
    DPTableViewCellSegmentedControlPositionTop,
    DPTableViewCellSegmentedControlPositionMiddle,
    DPTableViewCellSegmentedControlPositionBottom
} DPTableViewCellSegmentedControlPosition;

@interface DPTableViewCellSegmentedControl : UIControl

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *itemSelectedState;
@property (nonatomic, assign) BOOL allowMultipleSelection;
@property (nonatomic, assign) DPTableViewCellSegmentedControlPosition cellPosition;

- (id)initWithItems:(NSArray *)items;

- (UISegmentedControl *)seg;

@end
