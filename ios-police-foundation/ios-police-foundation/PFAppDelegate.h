//
//  PFAppDelegate.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 4/26/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPostDetailsViewController.h"

@interface PFAppDelegate : UIResponder <UIApplicationDelegate>

// state
@property (strong, nonatomic) NSString * selectedCategorySlug;
@property (strong, nonatomic) NSString * selectedTagSlug;

@property (strong, nonatomic) PFPostDetailsViewController * detailsViewController;

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;

@end
