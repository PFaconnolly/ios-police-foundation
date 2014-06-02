//
//  PFNewsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFNewsViewController.h"

@interface PFNewsViewController ()

@end

@implementation PFNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"News";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
