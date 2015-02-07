//
//  PFPostsViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFRefreshableCollectionViewController.h"
#import "PFWordPressCategory.h"
#import "PFWordPressTag.h"

@interface PFPostsViewController : PFRefreshableCollectionViewController

@property (strong, nonatomic) PFWordPressCategory * category;
@property (strong, nonatomic) PFWordPressTag * tag;

@end
