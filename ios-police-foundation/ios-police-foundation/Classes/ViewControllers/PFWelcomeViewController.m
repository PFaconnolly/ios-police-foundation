//
//  PFWelcomeViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWelcomeViewController.h"

@interface PFWelcomeViewController ()

@property (strong, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)okButtonTapped:(id)sender;

@end

@implementation PFWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.okButton.layer.borderWidth = 2;
    self.okButton.layer.cornerRadius = 5;
    self.okButton.layer.borderColor = [[UIColor whiteColor] CGColor];
}

#pragma mark - IBActions

- (IBAction)okButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
