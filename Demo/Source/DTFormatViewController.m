//
//  DTRTEFormatViewController.m
//  DTRichTextEditor
//
//  Created by Daniel Phillips on 14/04/2013.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <DTCoreText/DTCoreText.h>

#import "DTFormatViewController.h"
#import "DTFormatOverviewViewController.h"
#import "DTFormatFontFamilyTableViewController.h"

@interface DTFormatViewController ()<DTInternalFormatProtocol>

@end

@implementation DTFormatViewController

@synthesize fontDescriptor = _fontDescriptor;

- (id)init
{
    self = [super init];
	
    if (self)
	{
        self.textAlignment = -1;
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DTFormatOverviewViewController *homeFormatController = [[DTFormatOverviewViewController alloc] init];
    self.viewControllers = @[homeFormatController];
}

- (CGSize)contentSizeForViewInPopover
{
    return self.topViewController.contentSizeForViewInPopover;
}

- (void)setFontDescriptor:(DTCoreTextFontDescriptor *)fontDescriptor
{
    if (fontDescriptor == _fontDescriptor)
	{
        return;
	}

    _fontDescriptor = fontDescriptor;
    
    if (self.viewControllers.count > 0)
	{
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
		
        if ([homeFormatController.visibleTableViewController isKindOfClass:[UITableViewController class]])
		{
            [((UITableViewController *)homeFormatController.visibleTableViewController).tableView reloadData];
        }
		
        if ([self.topViewController isKindOfClass:[DTFormatFontFamilyTableViewController class]])
        {
            DTFormatFontFamilyTableViewController *fontFamilyController = (DTFormatFontFamilyTableViewController *)self.topViewController;
            [fontFamilyController setSelectedFontFamily:fontDescriptor.fontFamily];
        }
    }
}

- (void)setUnderline:(BOOL)underline
{
    _underline = underline;
    
    if (self.viewControllers.count > 0)
	{
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
        if ([homeFormatController.visibleTableViewController isKindOfClass:[UITableViewController class]]){
            [((UITableViewController *)homeFormatController.visibleTableViewController).tableView reloadData];
        }
    }
}

- (void)setHyperlink:(NSURL *)hyperlink
{
    if (_hyperlink == hyperlink)
	{
        return;
	}
    
    _hyperlink = [hyperlink copy];
    
    if (self.viewControllers.count > 0)
	{
        DTFormatOverviewViewController *homeFormatController = self.viewControllers[0];
		
        if ([homeFormatController.visibleTableViewController isKindOfClass:[UITableViewController class]])
		{
            [((UITableViewController *)homeFormatController.visibleTableViewController).tableView reloadData];
        }
    }
}

#pragma mark - DTInternalFormatProtocol methods

- (void)applyFont:(DTCoreTextFontDescriptor *)font
{
    CGFloat pointSize = self.fontDescriptor.pointSize;
    
    self.fontDescriptor = font;
    self.fontDescriptor.pointSize = pointSize;
    
    [self.formatDelegate formatDidSelectFont:self.fontDescriptor];
}

- (void)applyFontSize:(CGFloat)pointSzie
{
    self.fontDescriptor.pointSize = pointSzie;
    [self.formatDelegate formatDidSelectFont:self.fontDescriptor];
}

- (void)applyBold:(BOOL)active
{
    self.fontDescriptor.boldTrait = active;
    [self.formatDelegate formatDidToggleBold];
}

- (void)applyItalic:(BOOL)active
{
    self.fontDescriptor.italicTrait = active;
    [self.formatDelegate formatDidToggleItalic];
}

- (void)applyUnderline:(BOOL)active
{
    _underline = active;
    [self.formatDelegate formatDidToggleUnderline];
}

- (void)applyStrikethrough:(BOOL)active
{
    _strikethrough = active;
    [self.formatDelegate formatDidToggleStrikethrough];
}

- (void)applyTextAlignment:(CTTextAlignment)alignment
{
    [self.formatDelegate formatDidChangeTextAlignment:alignment];
}

- (void)decreaseTabulation
{
    [self.formatDelegate decreaseTabulation];
}

- (void)increaseTabulation
{
    [self.formatDelegate increaseTabulation];
}

- (void)toggleListType:(DTCSSListStyleType)listType
{
    if (self.listType == listType)
	{
        return;
	}
    
    self.listType = listType;
    
    [self.formatDelegate toggleListType:self.listType];
}

- (void)applyHyperlinkToSelectedText:(NSURL *)url
{
    if (self.hyperlink == url)
	{
        return;
	}
    
    self.hyperlink = url;
    
    [self.formatDelegate applyHyperlinkToSelectedText:self.hyperlink];
}

#pragma mark - Event bubbling

- (void)userPressedDone:(id)sender
{
    [self.formatDelegate formatViewControllerUserDidFinish:self];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        
        CGImageRef iref = [representation fullScreenImage];
        if (iref)
		{
            UIImage *theThumbnail = [UIImage imageWithCGImage:iref];
			[self.formatDelegate replaceCurrentSelectionWithPhoto:theThumbnail];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    };
	
	
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
	
    if (imageURL)
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
}

#pragma mark image picker hacks
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![navigationController isKindOfClass:[UIImagePickerController class]])
	{
        return;
	}

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
        return;
	}
    
    UINavigationItem *item = [viewController navigationItem];
    
    if (!item.rightBarButtonItems)
	{
        [item setValue:nil forKey:@"_customRightViews"];
    }
	else
	{
        [item setRightBarButtonItems:nil];
    }
}

@end
