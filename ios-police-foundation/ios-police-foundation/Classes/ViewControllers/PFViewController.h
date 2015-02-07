//
//  PFViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

typedef NS_ENUM(NSInteger, PFViewControllerOrientation) {
    PFViewControllerOrientationLandscape,
    PFViewControllerOrientationPortrait
};

@interface PFViewController : GAITrackedViewController

@property (nonatomic) PFViewControllerOrientation orientation;

- (void)showBarberPole;
- (void)hideBarberPole;

- (void)viewControllerWillChangeToOrientation:(PFViewControllerOrientation)orientation;

@end
