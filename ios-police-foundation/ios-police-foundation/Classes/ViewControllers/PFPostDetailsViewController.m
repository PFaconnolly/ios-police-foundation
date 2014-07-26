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

@interface PFPostDetailsViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentView;
@property (strong, nonatomic) PFBarberPoleView * barberPoleView;

// use with pad UI idiom
@property (strong, nonatomic) UIPopoverController * popController;

@end

@implementation PFPostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.barberPoleView = [[PFBarberPoleView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), 20)];
    self.title = @"Post";
    
    BOOL hasLaunchedApp = [[NSUserDefaults standardUserDefaults] boolForKey:kPFUserDefaultsHasLaunchedAppKey];
    
    if ( ! hasLaunchedApp ) {
        [[PFHTTPRequestOperationManager sharedManager] getLastestPostWithParameters:nil
                                                                       successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                           [self processWordPressPost:responseObject];
                                                                       } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                           NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                                           [exception raise];
                                                                           [self.barberPoleView removeFromSuperview];
                                                                       }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ( self.rssPost ) {
        [self refreshRssPost];
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

- (void)fetchWordPressPost {
    
    [self.view addSubview:self.barberPoleView];
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:self.wordPressPostId
                                                      parameters:nil
                                                    successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                        
                                                        [self processWordPressPost:responseObject];
                                                    }
                                                    failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                        [exception raise];
                                                        [self.barberPoleView removeFromSuperview];
                                                    }];
}

- (void)processWordPressPost:(id)responseObject {
    if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
        NSDictionary * response = (NSDictionary *)responseObject;
        self.titleLabel.text = [response objectForKey:@"title"];
        
        NSDate * date = [NSDate pfDateFromIso8601String:[response objectForKey:@"date"]];
        
        self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        
        NSString * content = [[response objectForKey:@"content"] pfStringByStrippingHTML];
        [self.contentView setText:content];
    }
    [self.barberPoleView removeFromSuperview];
}

- (void)refreshRssPost {
    NSDate * date = [NSDate pfDateFromRfc822String:[self.rssPost objectForKey:@"pubDate"]];
    NSString * content = [[self.rssPost objectForKey:@"description"] pfStringByStrippingHTML];
    
    self.titleLabel.text = [self.rssPost objectForKey:@"title"];
    self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
    
    [self.contentView setText:content];
}

@end
