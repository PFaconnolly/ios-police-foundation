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
@property (assign, nonatomic) BOOL didSetupConstraints;

@end

@implementation PFViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    self.barberPoleView = [[PFBarberPoleView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             CGRectGetWidth(self.view.frame),
                                                                             20)];
    
    // add empty back button title
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:nil
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.barberPoleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20);
}


#pragma mark - Public Methods

- (void)showBarberPole {
    [self.view addSubview:self.barberPoleView];
}

- (void)hideBarberPole {
    [self.barberPoleView removeFromSuperview];
}

@end
