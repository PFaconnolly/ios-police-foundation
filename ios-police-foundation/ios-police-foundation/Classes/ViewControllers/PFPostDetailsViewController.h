//
//  PFPostDetailsViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFViewController.h"
#import "PFRSSPost.h"

@interface PFPostDetailsViewController : PFViewController

@property (strong, nonatomic) PFRSSPost * rssPost;
@property (strong, nonatomic) NSString * wordPressPostId;

@end
