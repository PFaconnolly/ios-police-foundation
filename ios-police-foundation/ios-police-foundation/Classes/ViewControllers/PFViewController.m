//
//  PFViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFViewController.h"
#import "PFBarberPoleView.h"

@interface PFViewController()

@property (strong, nonatomic) PFBarberPoleView * barberPoleView;

@end

@implementation PFViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    self.barberPoleView = [[PFBarberPoleView alloc] initWithFrame:CGRectMake(0,
                                                                             60,
                                                                             CGRectGetWidth(self.view.frame),
                                                                             20)];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    // TO DO: Apply layout constraints to barber pole to position it right under the navigation bar
}

#pragma mark - Public Methods

- (void)showBarberPole {
    [self.view addSubview:self.barberPoleView];
}

- (void)hideBarberPole {
    [self.barberPoleView removeFromSuperview];
}

@end
