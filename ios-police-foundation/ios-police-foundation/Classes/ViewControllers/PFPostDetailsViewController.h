//
//  PFPostDetailsViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPostSelectionDelegate.h"

@interface PFPostDetailsViewController : UIViewController <PFPostSelectionDelegate>

@property (strong, nonatomic) NSString * postId;

- (void)selectPostWithId:(NSString *)postId;

@end
