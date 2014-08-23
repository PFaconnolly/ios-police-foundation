//
//  PFTabBarController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/23/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTabBarController.h"
#import "PFWelcomeViewController.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFTabBarController () <PFWelcomeSelectorDelegate>

@end

@implementation PFTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * tab, NSUInteger idx, BOOL *stop) {
            tab.image = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
            tab.selectedImage = [tab.selectedImage imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL hasLaunchedApp = [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsHasLaunchedAppKey];
    
    if ( ! hasLaunchedApp ) {
        PFWelcomeViewController * welcomeViewController = [[PFWelcomeViewController alloc] initWithDelegate:self];
        [self presentViewController:welcomeViewController animated:YES completion:^{
            // update has launched app key
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPFUserDefaultsHasLaunchedAppKey];
        }];
    }
}

#pragma mark - Welcome Selector Delegate methods

- (void)startWithScreen:(PFScreens)screen {
    DDLogVerbose(@"start with screen: %i", screen);
    switch(screen) {
        case PFScreen_Research:
            [self setSelectedIndex:0];
            break;
        case PFScreen_News:
            [self setSelectedIndex:1];
            break;
        case PFScreen_About:
            [self setSelectedIndex:2];
            break;
        default:
            [self setSelectedIndex:0];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];    
}

@end
