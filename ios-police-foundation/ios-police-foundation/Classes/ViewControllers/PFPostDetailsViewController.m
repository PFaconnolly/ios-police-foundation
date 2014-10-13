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

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

@interface PFPostDetailsViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem * attachmentBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem * shareBarButtonItem;
@property (strong, nonatomic) IBOutlet UIWebView * contentWebView;
@property (strong, nonatomic) NSMutableArray * rightBarButtonItems;

@property (strong, nonatomic) PFPost * wordPressPost;

@end

@implementation PFPostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)setRssPost:(PFRSSPost *)rssPost {
    _rssPost = rssPost;
    [self refreshRssPost];
}


#pragma mark Private methods

- (void)shareButtonTapped:(id)sender {

    NSString * URLString = nil;
    
    if ( _wordPressPost ) {
        URLString = _wordPressPost.link;
    } else if ( _rssPost ) {
        URLString = _rssPost.link;
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
    
    if ( self.wordPressPost.attachments && self.wordPressPost.attachments.allKeys.count > 0 ) {
        for( id key in self.wordPressPost.attachments.allKeys ) {
            NSDictionary * attachment = self.wordPressPost.attachments[key];
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
                                                    successBlock:^(AFHTTPRequestOperation *operation, PFPost * post) {
                                                        self.wordPressPost = post;
                                                        
                                                        NSString * html = [NSString pfStyledHTMLDocumentWithTitle:self.wordPressPost.title date:[NSString pfMediumDateStringFromDate:self.wordPressPost.date] body:self.wordPressPost.content];
                                                        NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
                                                        [self.contentWebView loadHTMLString:html baseURL:baseURL];
                                                        
                                                        // check for attachments and hide/show attachments button
                                                        if ( self.wordPressPost.attachments && self.wordPressPost.attachments.allKeys.count > 0 ) {
                                                            self.rightBarButtonItems = [NSMutableArray arrayWithObjects:self.shareBarButtonItem, self.attachmentBarButtonItem, nil];
                                                            self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
                                                        }
                                                        
                                                        [self hideBarberPole];
                                                    }
                                                    failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                        [self hideBarberPole];
                                                    }];
}


- (void)refreshRssPost {
    NSString * dateString = [NSString pfMediumDateStringFromDate:self.rssPost.date];
    NSString * html = [NSString pfStyledHTMLDocumentWithTitle:self.rssPost.title date:dateString body:self.rssPost.content];
    NSURL * baseURL = [NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath];
    [self.contentWebView loadHTMLString:html baseURL:baseURL];
}

@end
