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

@interface PFAboutViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIBarButtonItem * contactButton;
@property (strong, nonatomic) IBOutlet UIWebView * contentWebView;

@end

@implementation PFAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"About";
    
    if ( [MFMailComposeViewController canSendMail] ) {
        self.contactButton = [[UIBarButtonItem alloc] initWithTitle:@"Contact Us" style:UIBarButtonItemStylePlain target:self action:@selector(contactButtonTapped:)];
        self.navigationItem.rightBarButtonItem = self.contactButton;
    }
    
    [self fetchWordPressPost];
    
    [self.contentWebView setMediaPlaybackRequiresUserAction:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"About Screen";
}

- (void)contactButtonTapped:(id)sender {
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a contact category:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Cambridge Police Exec. Prog.", @"Crime Mapping M.S.S.", @"Fellowship Program", @"General Inquiry", @"Publication Requst", nil];
    
    [actionSheet showFromBarButtonItem:self.contactButton animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // cancel button index 5
    if ( buttonIndex <= 4 ) {
        
        NSString * mailSubject = @"General Inquiry";
        
        switch (buttonIndex) {
            case 0: mailSubject = @"Cambridge Police Executive Programme"; break;
            case 1: mailSubject = @"Crime Mapping Manuscript"; break;
            case 2: mailSubject = @"Fellowship Program"; break;
            case 3: mailSubject = @"General Inquiry"; break;
            case 4: mailSubject = @"Publication Request"; break;
            default: break;
        }
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[kPFInfoContactEmailAddress]];
            [composeViewController setSubject:mailSubject];
            [self presentViewController:composeViewController animated:YES completion:nil];
        }
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
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:WP_ABOUT_CONTENT_POST_ID
                                                      parameters:nil
                                                    successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                        [self processWordPressPost:responseObject];
                                                    }
                                                    failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                        [self hideBarberPole];
                                                    }];
}

- (void)processWordPressPost:(id)responseObject {
    [self hideBarberPole];
    
    if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
        NSDictionary * wordPressPost = (NSDictionary *)responseObject;
        NSString * titleString = [[wordPressPost objectForKey:WP_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];
        NSDate * date = [NSDate pfDateFromIso8601String:[wordPressPost objectForKey:WP_POST_DATE_KEY]];
        NSString * dateString = [NSString pfMediumDateStringFromDate:date];
        
        NSString * content = [wordPressPost objectForKey:WP_POST_CONTENT_KEY];
        NSString * html = [NSString pfStyledHTMLDocumentWithTitle:titleString date:dateString body:content];
        NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
        
        [self.contentWebView loadHTMLString:html baseURL:baseURL];
    }
}


@end
