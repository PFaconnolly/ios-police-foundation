//
//  UISplitViewController+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/30/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UISplitViewController+PFExtensions.h"
#import "PFWelcomeViewController.h"

@implementation UISplitViewController (PFExtensions)

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL hasLaunchedApp = [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsHasLaunchedAppKey];
    
    if ( ! hasLaunchedApp ) {
        PFWelcomeViewController * welcomeViewController = [[PFWelcomeViewController alloc] initWithNibName:@"PFWelcomeViewController~iPad" bundle:nil];
        [self presentViewController:welcomeViewController animated:YES completion:^{
            // update has launched app key
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPFUserDefaultsHasLaunchedAppKey];
        }];
    }
}

@end
