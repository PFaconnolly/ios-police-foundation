//
//  PFRefreshableViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/22/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFRefreshableViewController.h"

@interface PFRefreshableViewController ()

@end

@implementation PFRefreshableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)refreshButtonTapped:(id)sender {
    if ( self.refreshBlock ) {
        self.refreshBlock();
    }
}

@end
