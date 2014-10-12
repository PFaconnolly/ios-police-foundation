//
//  PFPostDetailsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostDetailsViewController.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFBarberPoleView.h"
#import "PFFileDownloadManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFPostDetailsViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem * attachmentBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem * shareBarButtonItem;
@property (strong, nonatomic) IBOutlet UIWebView * contentWebView;
@property (strong, nonatomic) NSMutableArray * rightBarButtonItems;

// use with pad UI idiom
@property (strong, nonatomic) UIPopoverController * popController;

@property (strong, nonatomic) NSDictionary * wordPressPost;

@end

@implementation PFPostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Post";

    // set up right bar button items
    self.attachmentBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Paperclip Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(attachmentButtonTapped:)];
    self.shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)];
    self.rightBarButtonItems = [NSMutableArray arrayWithObjects:self.shareBarButtonItem, nil];
    self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    
    [self.contentWebView setMediaPlaybackRequiresUserAction:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Post Details Screen";
    
    if ( self.rssPost ) {
        [self refreshRssPost];
    } else if ( self.wordPressPostId ) {
        [self fetchWordPressPost];
    } else {
        // fetch the latest post
        [[PFHTTPRequestOperationManager sharedManager] getLastestPostWithParameters:nil
                                                                       successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                           [self processWordPressPost:responseObject];
                                                                       } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                           [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                           [self hideBarberPole];
                                                                       }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}


#pragma mark UIWebView methods

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}


#pragma mark - Setters

- (void)setWordPressPostId:(NSString *)wordPressPostId {
    _wordPressPostId = wordPressPostId;
    [self fetchWordPressPost];
}

- (void)setRssPost:(NSDictionary *)rssPost {
    _rssPost = rssPost;
    [self refreshRssPost];
}


#pragma mark Private methods

- (void)shareButtonTapped:(id)sender {

    NSString * URLString = nil;
    
    if ( _wordPressPost ) {
        URLString = [_wordPressPost objectForKey:WP_ATTACHMENT_URL_KEY];
    } else if ( _rssPost ) {
        URLString = [_rssPost objectForKey:RSS_POST_LINK_KEY];
    } else {
        // fall back
        URLString = @"http://www.policefoundation.org";
    }
    
    NSURL * URL = [NSURL URLWithString:URLString];
    NSArray * sharingItems = [NSArray arrayWithObjects:URL, nil];
    
    // track the file name that was shared
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SHARED_ITEM_WITH_URL_ACTION label:URLString value:nil];
    
    UIActivityViewController * activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    // iOS 8 requires that activity controllers be presented from a UIView
    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.barButtonItem = self.shareBarButtonItem;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)attachmentButtonTapped:(id)sender {
    
    // TO DO: (future)
    // detect if there are more than 1 attachments
    
    NSURL * attachmentURL = nil;
    
    NSDictionary * attachments = (NSDictionary *)[self.wordPressPost objectForKey:WP_POST_ATTACHMENTS_KEY];
    if ( attachments && attachments.allKeys.count > 0 ) {
        for( id key in attachments.allKeys ) {
            NSDictionary * attachment = attachments[key];
            attachmentURL = [NSURL URLWithString:[attachment objectForKey:WP_ATTACHMENT_URL_KEY]];
            break;
        }
    }
    
    [self showBarberPole];
    self.attachmentBarButtonItem.enabled = NO;
    
    @weakify(self);
    [[PFFileDownloadManager sharedManager] downloadFileWithURL:attachmentURL withCompletion:^(NSURL * fileURL, NSError * error) {
        @strongify(self);
        [self hideBarberPole];
        self->_attachmentBarButtonItem.enabled = YES;
        
        if ( error ) {
            [UIAlertView pfShowWithTitle:@"File could not be downloaded" message:error.localizedDescription];
            return;
        }
        
        // track the file name that was viewed
        NSString * fileName = [fileURL lastPathComponent];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_VIEWED_FILE_NAME_ACTION label:fileName value:nil];
        
        // Fire up the document interaction controller
        UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        interactionController.delegate = self;
        [interactionController presentPreviewAnimated:YES];
    }];
}

- (void)fetchWordPressPost {
    [self showBarberPole];
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:self.wordPressPostId
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
        self.wordPressPost = (NSDictionary *)responseObject;
        NSString * titleString = [[self.wordPressPost objectForKey:WP_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];        
        NSDate * date = [NSDate pfDateFromIso8601String:[self.wordPressPost objectForKey:WP_POST_DATE_KEY]];
        NSString * dateString = [NSString pfMediumDateStringFromDate:date];
        
        NSString * content = [self.wordPressPost objectForKey:WP_POST_CONTENT_KEY];
        NSString * html = [NSString pfStyledHTMLDocumentWithTitle:titleString date:dateString body:content];
        NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
        
        [self.contentWebView loadHTMLString:html baseURL:baseURL];
        
        // check for attachments and hide/show attachments button
        NSDictionary * attachments = (NSDictionary *)[self.wordPressPost objectForKey:WP_POST_ATTACHMENTS_KEY];
        if ( attachments && attachments.allKeys.count > 0 ) {
            self.rightBarButtonItems = [NSMutableArray arrayWithObjects:self.shareBarButtonItem, self.attachmentBarButtonItem, nil];
            self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
        }
    }
}

- (void)refreshRssPost {
    NSString * titleString = [[self.rssPost objectForKey:RSS_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];

    NSDate * date = [NSDate pfDateFromRfc822String:[self.rssPost objectForKey:RSS_POST_PUBLISH_DATE_KEY]];
    NSString * dateString = [NSString pfMediumDateStringFromDate:date];
    
    NSString * content = [self.rssPost objectForKey:RSS_POST_DESCRIPTION_KEY];
    NSString * html = [NSString pfStyledHTMLDocumentWithTitle:titleString date:dateString body:content];
    NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
    [self.contentWebView loadHTMLString:html baseURL:baseURL];
}

@end
