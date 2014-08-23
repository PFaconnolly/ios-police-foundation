//
//  PFWelcomeViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PFScreen_Research = 0,
    PFScreen_News,
    PFScreen_About
} PFScreens;

@protocol PFWelcomeSelectorDelegate <NSObject>

- (void)startWithScreen:(PFScreens)screen;

@end

@interface PFWelcomeViewController : UIViewController

- (id)initWithDelegate:(id<PFWelcomeSelectorDelegate>)delegate;

@end
