//
//  DPTableViewCellSegmentedControl.m
//  ui
//
//  Created by Daniel Phillips on 07/05/2013.
//  Copyright (c) 2013 Daniel Phillips. All rights reserved.
//

#import "DPTableViewCellSegmentedControl.h"

@interface DPTableViewCellSegmentedControl ()
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIImage *imageLeftOn;
@property (nonatomic, strong) UIImage *imageLeftOff;
@property (nonatomic, strong) UIImage *imageCenterOn;
@property (nonatomic, strong) UIImage *imageCenterOff;
@property (nonatomic, strong) UIImage *imageRightOn;
@property (nonatomic, strong) UIImage *imageRightOff;
@end

@implementation DPTableViewCellSegmentedControl

- (id)init
{
    self = [super init];
    if(self){
        self.items = @[];
        self.buttons = @[];
        self.selectedIndex = 0;
        self.frame = CGRectZero;
        self.cellPosition = DPTableViewCellSegmentedControlPositionSingle;
        self.allowMultipleSelection = YES;
    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    self = [self init];
    if(self){
        self.items = items;
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    if(_items == items)
        return;
    
    _items = items;
    
    [self setNeedsDisplay];
}

- (void)setCellPosition:(DPTableViewCellSegmentedControlPosition)cellPosition
{
    if(_cellPosition == cellPosition)
        return;
    
    _cellPosition = cellPosition;
    
    UIImage *leftCapOn;
    UIImage *leftCapOff;
    UIImage *centerCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
    UIImage *centerCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Unselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
    UIImage *rightCapOn;
    UIImage *rightCapOff;
    
    
    switch (self.cellPosition) {
        case DPTableViewCellSegmentedControlPositionSingle:
        {
            leftCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Selected_Blue_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            leftCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Unselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            rightCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Selected_Blue_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
            rightCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Unselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
        }
            break;
        case DPTableViewCellSegmentedControlPositionTop:
        {
            leftCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Selected_Blue_Top_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            leftCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Unselected_Top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            rightCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Selected_Blue_Top_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
            rightCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Unselected_Top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
            centerCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Selected_Blue_Top_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            centerCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Unselected_Top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
        }
            break;
        case DPTableViewCellSegmentedControlPositionMiddle:
        {
            leftCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            leftCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Unselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            rightCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            rightCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Unselected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
        }
            break;
        case DPTableViewCellSegmentedControlPositionBottom:
        {
            leftCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            leftCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_LeftCap_Unselected_Bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            rightCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
            rightCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_RightCap_Unselected_Bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 10.0) resizingMode:UIImageResizingModeTile];
            centerCapOn = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Selected_Blue_Bottom_ShadowNone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
            centerCapOff = [[UIImage imageNamed:@"TSK_SegmentedControl_Center_Unselected_Bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 1.0) resizingMode:UIImageResizingModeTile];
        }
            break;
            
        default:
            break;
    }

    
    self.imageCenterOn  = centerCapOn;
    self.imageCenterOff = centerCapOff;
    self.imageLeftOn    = leftCapOn;
    self.imageLeftOff   = leftCapOff;
    self.imageRightOn   = rightCapOn;
    self.imageRightOff  = rightCapOff;

    [self clearButtons];
        
    [self setNeedsDisplay];
}

- (void)clearButtons{
    for (UIButton *button in self.buttons){
        [button removeFromSuperview];
    }
    
    self.buttons = @[];
}

- (void)initializeImages
{
    NSMutableArray *buttonsArray = [NSMutableArray array];

    for (NSInteger i = 0; i < self.items.count; i++){
        
        id itemName = self.items[i];
        
        if( ![itemName isKindOfClass:[NSString class]] )
            continue;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:itemName forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        
        if (i == 0){
            // left cap
            [button setBackgroundImage:self.imageLeftOff forState:UIControlStateNormal];
            [button setBackgroundImage:self.imageLeftOn forState:UIControlStateHighlighted];
            [button setBackgroundImage:self.imageLeftOn forState:UIControlStateSelected];
            [button setBackgroundImage:self.imageLeftOn forState:UIControlStateHighlighted | UIControlStateSelected];
        }else if (i == self.items.count - 1){
            // right cap
            [button setBackgroundImage:self.imageRightOff forState:UIControlStateNormal];
            [button setBackgroundImage:self.imageRightOn forState:UIControlStateHighlighted];
            [button setBackgroundImage:self.imageRightOn forState:UIControlStateSelected];
            [button setBackgroundImage:self.imageRightOn forState:UIControlStateHighlighted | UIControlStateSelected];
        }else{
            [button setBackgroundImage:self.imageCenterOff forState:UIControlStateNormal];
            [button setBackgroundImage:self.imageCenterOn forState:UIControlStateHighlighted];
            [button setBackgroundImage:self.imageCenterOn forState:UIControlStateSelected];
            [button setBackgroundImage:self.imageCenterOn forState:UIControlStateHighlighted | UIControlStateSelected];
        }
        
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
        
        [buttonsArray addObject:button];

        [self addSubview:button];
    }
    
    self.buttons = buttonsArray;
}

- (void)layoutSubviews
{
    if (!self.buttons || self.buttons.count == 0){
        [self initializeImages];
    }
        
    CGFloat width = CGRectGetWidth(self.bounds) / self.items.count;
    CGFloat height = self.imageCenterOff.size.height;
    
    for (NSInteger i = 0; i < self.buttons.count; i++){
        UIButton *button = self.buttons[i];
        if (!button)
            continue;
        
        button.selected = [self.itemSelectedState[i] boolValue];
                        
        [button setFrame:CGRectMake( i * width , 0.0, width, height)];
    }
}

- (void)buttonTapped:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    // toggle adjecant images to show/hide shaddows.
    
    self.selectedIndex = [self.buttons indexOfObject:sender];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
