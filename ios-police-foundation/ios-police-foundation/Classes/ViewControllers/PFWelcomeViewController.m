//
//  PFWelcomeViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWelcomeViewController.h"

@interface PFWelcomeViewController ()

@property (nonatomic, weak) id<PFWelcomeSelectorDelegate> delegate;

@end

@implementation PFWelcomeViewController

- (id)initWithDelegate:(id<PFWelcomeSelectorDelegate>)delegate {
    NSString * nibName = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"PFWelcomeViewController" : @"PFWelcomeViewController~iPad";
    self = [super initWithNibName:nibName bundle:nil];
    if ( self != nil ) {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

// only supports portrait interface orienation
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)dismissButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)researchButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_Research];
    }
}

- (IBAction)newsButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_News];
    }
}

- (IBAction)aboutButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_About];
    }
}

@end
