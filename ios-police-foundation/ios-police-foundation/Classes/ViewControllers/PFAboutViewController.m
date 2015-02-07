//
//  PFAboutViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import "PFHTTPRequestOperationManager.h"
#import "PFWelcomeViewController.h"

@interface PFAboutViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIBarButtonItem * contactButton;
@property (nonatomic, strong) UIBarButtonItem * helpButton;
@property (strong, nonatomic) IBOutlet UIWebView * contentWebView;
@property (strong, nonatomic) UIAlertView * sendMailAlertView;

@end

@implementation PFAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"About";
    
    // create help button
    self.helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStylePlain target:self action:@selector(helpButtonTapped:)];
    
    // create contact button
    if ( [MFMailComposeViewController canSendMail] ) {
        self.contactButton = [[UIBarButtonItem alloc] initWithTitle:@"Contact Us" style:UIBarButtonItemStylePlain target:self action:@selector(contactButtonTapped:)];
    }
    
    // set up bar button items
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        
        if ( self.contactButton ) {
            self.navigationItem.rightBarButtonItems = @[self.helpButton, self.contactButton];
        } else {
            self.navigationItem.rightBarButtonItem = self.helpButton;
        }
        
    } else if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ) {

        self.navigationItem.leftBarButtonItem = self.helpButton;
        
        if ( self.contactButton ) {
            self.navigationItem.rightBarButtonItem = self.contactButton;
        }
    }
    
    [self.contentWebView setMediaPlaybackRequiresUserAction:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchWordPressPost];
    self.screenName = @"About Screen";
}

#pragma mark - Private methods

- (void)helpButtonTapped:(id)sender {
    PFWelcomeViewController * welcomeViewController = [[PFWelcomeViewController alloc] init];
    [self presentViewController:welcomeViewController animated:YES completion:nil];
}

- (void)contactButtonTapped:(id)sender {
    
    if ( [MFMailComposeViewController canSendMail] ) {
        MFMailComposeViewController * composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[kPFInfoContactEmailAddress]];
        [composeViewController setSubject:kPFInfoContactSubject];
        composeViewController.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        
        if ( ! self.sendMailAlertView ) {
            self.sendMailAlertView = [[UIAlertView alloc] initWithTitle:@"Mail is not available"
                                                                message:@"This app is not able to send email directly. Would you like to switch to the Mail app instead?"
                                                               delegate:self
                                                      cancelButtonTitle:@"No thanks."
                                                      otherButtonTitles:@"Yes, switch to mail.", nil];
        }
        [self.sendMailAlertView show];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch( buttonIndex ) {
        case 0: {
            
            // quit ...
            
            break;
        }
        case 1: {
            
            NSString * mailToString = [[NSString stringWithFormat:@"mailto:%@?subject=%@", kPFInfoContactEmailAddress, kPFInfoContactSubject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL * URL = [NSURL URLWithString:mailToString];
            [[UIApplication sharedApplication] openURL:URL];
            
            break;
        }
        default: break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)fetchWordPressPost {
    [self showBarberPole];
    
    // Fetch posts from blog ...
    @weakify(self);
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:WP_ABOUT_CONTENT_POST_ID
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
