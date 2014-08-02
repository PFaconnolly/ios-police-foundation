//
//  PFAppDelegate.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 4/26/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFAppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <Crashlytics/Crashlytics.h>
#import "PFCategoriesViewController.h"
#import "PFAboutViewController.h"
#import "PFNewsViewController.h"
#import "PFNavigationController.h"

@interface PFAppDelegate()

@end

@implementation PFAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setAppearance];
    [self setLogger];
    
    // Google Analytics
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    //[GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    /*[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-34908763-4"];
    

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"System Action"   // Event category (required)
                                                          action:@"App Launched"    // Event action (required)
                                                           label:nil                // Event label
                                                           value:nil] build]];      // Event value*/

    
    // Crashlytics
    [Crashlytics startWithAPIKey:@"4cc4ce965b769396e57af58ca8f2142491f099cd"];
    
    // Force crash:
    //NSString * test = @"12";
    //NSString * __unused subString = [test stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"1234"];
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        UISplitViewController * splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController * navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        self.detailsViewController = (id)navigationController.topViewController;
    }
    
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
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)setAppearance {
    
    UIColor * tintColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0];
    UIColor * barBackgroundColor = [UIColor colorWithRed:2/255.0 green:92/255.0 blue:190/255.0 alpha:1.0];
    UIColor * darkBlueColor = [UIColor colorWithRed:0 green:11/255.0 blue:112/255.0 alpha:0.8];
    
    // tab bar tint color
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        [[UITabBar appearance] setTintColor:tintColor];
        [[UITabBar appearance] setBarTintColor:barBackgroundColor];
    } else {
        [[UITabBar appearance] setTintColor:barBackgroundColor];
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    // navigation bar tint color
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        [[UINavigationBar appearance] setTintColor:tintColor];
        [[UINavigationBar appearance] setBarTintColor:barBackgroundColor];
        [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor],
                                                               UITextAttributeTextShadowColor: darkBlueColor,
                                                               UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}];
        [[UINavigationBar appearanceWhenContainedIn:[PFNavigationController class], nil] setBarTintColor:darkBlueColor];
    } else {
        [[UINavigationBar appearance] setTintColor:barBackgroundColor];
    }
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ) {
        if ( [self.window.rootViewController isKindOfClass:([UITabBarController class])] ) {
            UITabBarController * tabBarController = (UITabBarController *)self.window.rootViewController;
            
            NSArray * array = @[@{ @"image" : @"Star Tab Icon", @"selectedImage" : @"Star Tab Icon Selected" },
                                @{ @"image" : @"News Tab Icon", @"selectedImage" : @"News Tab Icon Selected" },
                                @{ @"image" : @"About Tab Icon", @"selectedImage" : @"About Tab Icon Selected" }];
            
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
}

- (void)setLogger {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ios_police_foundation" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ios_police_foundation.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
