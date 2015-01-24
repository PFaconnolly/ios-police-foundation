//
//  PFAppDelegate.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 4/26/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFAppDelegate.h"
#import "PFAnalyticsManager.h"
#import <Crashlytics/Crashlytics.h>

@interface PFAppDelegate()

@end

@implementation PFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setAppearance];
    [self setLogger];
    
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_SYSTEM_ACTION_CATEGORY action:GA_APPLICATION_LAUNCHED_ACTION label:nil value:nil];
    
    // Crashlytics
    [Crashlytics startWithAPIKey:@"4cc4ce965b769396e57af58ca8f2142491f099cd"];
    
    // Force crash:
    //NSString * test = @"12";
    //NSString * __unused subString = [test stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"1234"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)setAppearance {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIColor * tintColor = [UIColor colorWithRed:140/255.0 green:181/255.0 blue:227/255.0 alpha:1.0];
    UIColor * barBackgroundColor = [UIColor colorWithRed:2/255.0 green:92/255.0 blue:190/255.0 alpha:1.0];
    UIColor * darkBlueColor = [UIColor colorWithRed:0 green:11/255.0 blue:112/255.0 alpha:0.8];
    
    // tab bar tint color
    [[UITabBar appearance] setTintColor:tintColor];
    [[UITabBar appearance] setBarTintColor:barBackgroundColor];

    // tab bar items
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setTintColor:tintColor];
    [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setBarTintColor:barBackgroundColor];

    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: darkBlueColor];
    [shadow setShadowOffset: CGSizeMake(0, 0)];
    
    [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                          NSShadowAttributeName: shadow}];
    
    if ( [self.window.rootViewController isKindOfClass:([UITabBarController class])] ) {
        UITabBarController * tabBarController = (UITabBarController *)self.window.rootViewController;
        
        NSArray * array = @[@{ @"image" : @"Research Tab Icon", @"selectedImage" : @"Research Tab Icon Selected" },
                            @{ @"image" : @"RSS Tab Icon", @"selectedImage" : @"RSS Tab Icon Selected" },
                            @{ @"image" : @"About Tab Icon", @"selectedImage" : @"About Tab Icon Selected" },
                            @{ @"image" : @"Terms Tab Icon", @"selectedImage" : @"Terms Tab Icon Selected" },
                            @{ @"image" : @"Document Tab Icon", @"selectedImage" : @"Document Tab Icon Selected" }];
        
        [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * tabBarItem, NSUInteger __unused index, BOOL * __unused stop) {
            if ( [tabBarItem respondsToSelector:@selector(setImage:)] &&
                [tabBarItem respondsToSelector:@selector(setSelectedImage:)]) {
                
                NSDictionary * assetName = array[index];
                tabBarItem.image = [UIImage imageNamed:assetName[@"image"]];
                tabBarItem.selectedImage = [UIImage imageNamed:assetName[@"selectedImage"]];
            }
        }];
    }
    
}

- (void)setLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
