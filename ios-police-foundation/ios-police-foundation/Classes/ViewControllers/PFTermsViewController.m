//
//  PFTermsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/11/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTermsViewController.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFWelcomeViewController.h"

@interface PFTermsViewController()

@property (strong, nonatomic) IBOutlet UIWebView *contentWebView;

@end

@implementation PFTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Terms";
    [self.contentWebView setMediaPlaybackRequiresUserAction:NO];
    
    UIBarButtonItem * helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpButtonTapped:)];
    self.navigationItem.rightBarButtonItem = helpButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchWordPressPost];
    self.screenName = @"Terms Screen";
}

#pragma mark - Private methods

- (void)helpButtonTapped:(id)sender {
    PFWelcomeViewController * welcomeViewController = [[PFWelcomeViewController alloc] init];
    [self presentViewController:welcomeViewController animated:YES completion:nil];
}

- (void)fetchWordPressPost {
    [self showBarberPole];
    
    // Fetch posts from blog ...
    @weakify(self);
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:WP_TERMS_CONTENT_POST_ID
                                                      parameters:nil
                                                    successBlock:^(AFHTTPRequestOperation *operation, PFPost * post) {
                                                        @strongify(self);
                                                        NSString * html = [NSString pfStyledHTMLDocumentWithTitle:post.title
                                                                                                             date:[NSString pfMediumDateStringFromDate:post.date]
                                                                                                             body:post.content];
                                                        NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
                                                        [self->_contentWebView loadHTMLString:html baseURL:baseURL];
                                                        [self hideBarberPole];
                                                    }
                                                    failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                        [self hideBarberPole];
                                                    }];
}

@end
