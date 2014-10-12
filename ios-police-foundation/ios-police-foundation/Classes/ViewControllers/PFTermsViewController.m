//
//  PFTermsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/11/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTermsViewController.h"
#import "PFHTTPRequestOperationManager.h"

@interface PFTermsViewController()

@property (strong, nonatomic) IBOutlet UIWebView *contentWebView;

@end

@implementation PFTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Terms";
    
    [self fetchWordPressPost];
    
    [self.contentWebView setMediaPlaybackRequiresUserAction:NO];
}


#pragma mark - Private methods

- (void)fetchWordPressPost {
    [self showBarberPole];
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:WP_TERMS_CONTENT_POST_ID
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
