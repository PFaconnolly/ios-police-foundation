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

static NSString * ATTACHMENT_ID_KEY = @"ID";
static NSString * ATTACHMENT_URL_KEY = @"URL";
static NSString * ATTACHMENT_GUID_KEY = @"guid";
static NSString * ATTACHMENT_WIDTH_KEY = @"mime-type";

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

@interface PFPostDetailsViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentView;

@property (strong, nonatomic) UIBarButtonItem * attachmentBarButtonItem;

// use with pad UI idiom
@property (strong, nonatomic) UIPopoverController * popController;

@end

@implementation PFPostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Post";
    
    self.attachmentBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"File" style:UIBarButtonItemStylePlain target:self action:@selector(attachmentButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.attachmentBarButtonItem;
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
                                                                           NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                                           [exception raise];
                                                                           [self hideBarberPole];
                                                                       }];
        
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.rssPost = nil;
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
                                                        NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                        [exception raise];
                                                        [self hideBarberPole];
                                                    }];
}

- (void)processWordPressPost:(id)responseObject {
    if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
        NSDictionary * response = (NSDictionary *)responseObject;
        self.titleLabel.text = [response objectForKey:@"title"];
        
        NSDate * date = [NSDate pfDateFromIso8601String:[response objectForKey:@"date"]];
        
        self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        
        NSString * content = [[response objectForKey:@"content"] pfStringByConvertingHTMLToPlainText];
        [self.contentView setText:content];
        
        // process attachments
        NSDictionary * attachments = (NSDictionary *)[response objectForKey:@"attachments"];
        if ( attachments && attachments.allKeys.count > 0 ) {
            [self processAttachments:[response objectForKey:@"attachments"]];
        }
    }
    [self hideBarberPole];
}

- (void)refreshRssPost {
    NSDate * date = [NSDate pfDateFromRfc822String:[self.rssPost objectForKey:@"pubDate"]];
    NSString * content = [[self.rssPost objectForKey:@"description"] pfStringByConvertingHTMLToPlainText];
    
    self.titleLabel.text = [self.rssPost objectForKey:@"title"];
    self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
    
    [self.contentView setText:content];
}

- (void)processAttachments:(NSDictionary *)attachments {
    
    for( id key in attachments.allKeys ) {
        NSDictionary * attachment = attachments[key];
        NSString * URLString = [attachment objectForKey:@"URL"];
        NSString * fileName = [attachment objectForKey:@"name"];
        NSLog(@"name: %@ - url: %@", fileName, URLString);
    }
}

@end
