//
//  UITabBarController+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UITabBarController+PFExtensions.h"

@implementation UITabBarController (PFExtensions)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {    
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * tab, NSUInteger idx, BOOL *stop) {
            tab.image = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
            tab.selectedImage = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        }];
    }
}

@end
