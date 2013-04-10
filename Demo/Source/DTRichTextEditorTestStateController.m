//
//  DTRichTextEditorTestStateController.m
//  DTRichTextEditor
//
//  Created by Lee Hericks on 3/21/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTRichTextEditorTestStateController.h"
#import "DTRichTextEditorTestState.h"

typedef enum {
    DTSectionDTCoreText = 0,
    DTSectionDTRichTextEditor,
    DTSectionDTRichTextEditorViewDelegate,
    DTSectionCount
} DTSection;

typedef enum {
    DTCoreTextSectionRowDrawDebugFrames = 0,
    DTCoreTextSectionRowCount
} DTCoreTextSectionRow;

typedef enum {
    DTRichTextEditorSectionRowEditable = 0,
    DTRichTextEditorSectionRowCount
} DTRichTextEditorSectionRow;

typedef enum {
    DTRichTextEditorViewDelegateSectionRowBeginEditing = 0,
    DTRichTextEditorViewDelegateSectionRowEndEditing,
    DTRichTextEditorViewDelegateSectionRowCount
} DTRichTextEditorViewDelegateSectionRow;

@interface DTRichTextEditorTestStateController ()
@property (nonatomic, retain, readonly) UISwitch *drawDebugFramesSwitch;
@property (nonatomic, retain, readonly) UISwitch *editableSwitch;
@property (nonatomic, retain, readonly) UISwitch *beginEditingSwitch;
@property (nonatomic, retain, readonly) UISwitch *endEditingSwitch;
@end

@implementation DTRichTextEditorTestStateController

#pragma mark - Switches

@synthesize drawDebugFramesSwitch = _drawDebugFramesSwitch;

- (UISwitch *)drawDebugFramesSwitch
{
    if (_drawDebugFramesSwitch == nil)
    {
        _drawDebugFramesSwitch = [[UISwitch alloc] init];
        _drawDebugFramesSwitch.on = self.testState.shouldDrawDebugFrames;
        [_drawDebugFramesSwitch addTarget:self action:@selector(drawDebugFramesValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _drawDebugFramesSwitch;
}

- (void)drawDebugFramesValueChanged:(UISwitch *)aSwitch
{
    self.testState.shouldDrawDebugFrames = aSwitch.on;
}

@synthesize editableSwitch = _editableSwitch;

- (UISwitch *)editableSwitch
{
    if (_editableSwitch == nil)
    {
        _editableSwitch = [[UISwitch alloc] init];
        _editableSwitch.on = self.testState.editable;
        [_editableSwitch addTarget:self action:@selector(editableValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _editableSwitch;
}

- (void)editableValueChanged:(UISwitch *)aSwitch
{
    self.testState.editable = aSwitch.on;
}


@synthesize beginEditingSwitch = _beginEditingSwitch;

- (UISwitch *)beginEditingSwitch
{
    if (_beginEditingSwitch == nil)
    {
        _beginEditingSwitch = [[UISwitch alloc] init];
        _beginEditingSwitch.on = self.testState.blockShouldBeginEditing;
        [_beginEditingSwitch addTarget:self action:@selector(beginEditingSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _beginEditingSwitch;
}

- (void)beginEditingSwitchValueChanged:(UISwitch *)aSwitch
{
    self.testState.blockShouldBeginEditing = aSwitch.on;
}


@synthesize endEditingSwitch = _endEditingSwitch;

- (UISwitch *)endEditingSwitch
{
    if (_endEditingSwitch == nil)
    {
        _endEditingSwitch = [[UISwitch alloc] init];
        _endEditingSwitch.on = self.testState.blockShouldEndEditing;
        [_endEditingSwitch addTarget:self action:@selector(endEditingSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _endEditingSwitch;
}

- (void)endEditingSwitchValueChanged:(UISwitch *)aSwitch
{
    self.testState.blockShouldEndEditing = aSwitch.on;
}


#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Test Options";
    self.contentSizeForViewInPopover = CGSizeMake(480, 320);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.completion)
        self.completion(self.testState);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return DTSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case DTSectionDTCoreText:
            return DTCoreTextSectionRowCount;
            
        case DTSectionDTRichTextEditor:
            return DTRichTextEditorSectionRowCount;
            
        case DTSectionDTRichTextEditorViewDelegate:
            return DTRichTextEditorViewDelegateSectionRowCount;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        case DTSectionDTCoreText:
        {
            switch (indexPath.row)
            {
                case DTCoreTextSectionRowDrawDebugFrames:
                {
                    cell.textLabel.text = @"Draw Debug Frames";
                    cell.accessoryView = self.drawDebugFramesSwitch;
                    break;
                }
            }
            break;
        }
            
        case DTSectionDTRichTextEditor:
        {
            switch (indexPath.row)
            {
                case DTRichTextEditorSectionRowEditable:
                {
                    cell.textLabel.text = @"Editor is Editable";
                    cell.accessoryView = self.editableSwitch;
                    break;
                }
            }
            break;
        }
            
        case DTSectionDTRichTextEditorViewDelegate:
        {
            switch (indexPath.row)
            {
                case DTRichTextEditorViewDelegateSectionRowBeginEditing:
                {
                    cell.textLabel.text = @"shouldBeginEditing: return NO";
                    cell.accessoryView = self.beginEditingSwitch;
                    break;
                }
                    
                case DTRichTextEditorViewDelegateSectionRowEndEditing:
                {
                    cell.textLabel.text = @"shouldEndEditing: return NO";
                    cell.accessoryView = self.endEditingSwitch;
                    break;
                }
            }
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case DTSectionDTCoreText:
            return @"DTCoreText";
        
        case DTSectionDTRichTextEditor:
            return @"DTRichTextEditor";
            
        case DTSectionDTRichTextEditorViewDelegate:
            return @"DTRichTextEditorViewDelegate";
            
        default:
            return nil;
    }
}

@end
