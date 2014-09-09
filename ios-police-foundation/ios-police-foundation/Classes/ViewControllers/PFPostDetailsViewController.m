//
//  PFPostDetailsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostDetailsViewController.h"
#import "PFHTTPRequestOperationManager.h"
#import "NSString+PFExtensions.h"
#import "NSDate+PFExtensions.h"
#import "PFBarberPoleView.h"
#import "PFFileDownloadManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

static NSString * WP_POST_TITLE_KEY = @"title";
static NSString * WP_POST_DATE_KEY = @"date";
static NSString * WP_POST_CONTENT_KEY = @"content";
static NSString * WP_POST_ATTACHMENTS_KEY = @"attachments";

static NSString * WP_ATTACHMENT_ID_KEY = @"ID";
static NSString * WP_ATTACHMENT_URL_KEY = @"URL";
static NSString * WP_ATTACHMENT_GUID_KEY = @"guid";
static NSString * WP_ATTACHMENT_WIDTH_KEY = @"mime-type";

static NSString * RSS_POST_PUBLISH_DATE_KEY = @"pubDate";
static NSString * RSS_POST_DESCRIPTION_KEY = @"description";
static NSString * RSS_POST_TITLE_KEY = @"title";

@interface PFPostDetailsViewController () <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentView;
@property (strong, nonatomic) UIBarButtonItem * attachmentBarButtonItem;

// use with pad UI idiom
@property (strong, nonatomic) UIPopoverController * popController;

@property (strong, nonatomic) NSDictionary * wordPressPost;

@end

@implementation PFPostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Post";
    
    self.attachmentBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Paperclip Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(attachmentButtonTapped:)];
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        self.contentView.font = [UIFont fontWithName:@"Georgia" size:24.0f];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
                                                                           [UIAlertView showWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                           [self hideBarberPole];
                                                                       }];
    }
    
    self.screenName = @"Post Details Screen";
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.rssPost = nil;
    self.wordPressPost = nil;
} 


#pragma mark - UISplitViewControllerDelegate methods

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc {
    self.popController = pc;
    barButtonItem.title = @"Menu";
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController {
    pc.popoverContentSize = CGSizeMake(320, 1024);
    // iOS 7 has a weird 4 pixel width difference when presenting the view controller in a popover. set the view's frame here 
}


#pragma mark - PFPostSelectionDelegate methods

- (void)selectPostWithId:(NSString *)postId {
    self.wordPressPostId = postId;
}

- (void)selectPostWithRssPost:(NSDictionary *)rssPost {
    self.rssPost = rssPost;
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


#pragma mark - Private methods

- (void)attachmentButtonTapped:(id)sender {
    
    // TO DO:
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
            [UIAlertView showWithTitle:@"File could not be downloaded" message:error.localizedDescription];
            return;
        }
        
        // Fire up the document interaction controller
        UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        interactionController.delegate = self;
        [interactionController presentPreviewAnimated:YES];
    }];
}

#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
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
                                                        [UIAlertView showWithTitle:@"Request Failed" message:error.localizedDescription];
                                                        [self hideBarberPole];
                                                    }];
}

- (void)processWordPressPost:(id)responseObject {
    [self hideBarberPole];

    if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
        self.wordPressPost = (NSDictionary *)responseObject;
        self.titleLabel.text = [self.wordPressPost objectForKey:WP_POST_TITLE_KEY];
        
        NSDate * date = [NSDate pfDateFromIso8601String:[self.wordPressPost objectForKey:WP_POST_DATE_KEY]];
        
        self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        
        NSString * content = [[self.wordPressPost objectForKey:WP_POST_CONTENT_KEY] pfStringByConvertingHTMLToPlainText];
        [self.contentView setText:content];
        
        // check for attachments and hide/show attachments button
        NSDictionary * attachments = (NSDictionary *)[self.wordPressPost objectForKey:WP_POST_ATTACHMENTS_KEY];
        if ( attachments && attachments.allKeys.count > 0 ) {
            self.navigationItem.rightBarButtonItem = self.attachmentBarButtonItem;
        }
    }
}

- (void)refreshRssPost {
    NSDate * date = [NSDate pfDateFromRfc822String:[self.rssPost objectForKey:RSS_POST_PUBLISH_DATE_KEY]];
    NSString * content = [[self.rssPost objectForKey:RSS_POST_DESCRIPTION_KEY] pfStringByConvertingHTMLToPlainText];
    self.titleLabel.text = [self.rssPost objectForKey:RSS_POST_TITLE_KEY];
    self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
    [self.contentView setText:content];
}

@end
