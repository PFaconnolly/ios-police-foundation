//
//  PFPostsViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFRefreshableViewController.h"
#import "PFWordPressCategory.h"

@interface PFPostsViewController : PFRefreshableViewController

@property (strong, nonatomic) PFWordPressCategory * category;
@property (strong, nonatomic) NSDictionary * tag;

@end
