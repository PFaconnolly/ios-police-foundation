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
    self.postId = postId;
}

#pragma mark - Setters

- (void)setPostId:(NSString *)postId {
    _postId = postId;
    [self fetchPost];
}

#pragma mark - Private methods

- (void)fetchPost {
    
    [self.view addSubview:self.barberPoleView];
    
    @weakify(self)

    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:self.postId
                                                      parameters:nil
                                                    successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                        @strongify(self)
                                                        if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                            NSDictionary * response = (NSDictionary *)responseObject;
                                                            self.titleLabel.text = [response objectForKey:@"title"];
                                                            
                                                            NSDate * date = [NSDate pfDateFromIso8601String:[response objectForKey:@"date"]];
                                                            
                                                            self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
                                                            
                                                            NSString * content = [[response objectForKey:@"content"] pfStringByStrippingHTML];
                                                            [self.contentView setText:content];                                                                 }
                                                        [self.barberPoleView removeFromSuperview];
                                                        
                                                    }
                                                    failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                        [exception raise];
                                                        [self.barberPoleView removeFromSuperview];
                                                        
                                                    }];
}

@end
