//
//  PFPostsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostsViewController.h"
#import "PFAppDelegate.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFArrayDataSource.h"
#import "PFPostDetailsViewController.h"
#import "PFBarberPoleView.h"
#import "PFAnalyticsManager.h"
#import "PFCommonTableViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFPostsViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) PFArrayDataSource * postsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation PFPostsViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Posts";
    [self setupTableView];
    [self fetchPosts];
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchPosts];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.screenName = @"WordPress Post List Screen";
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.category = nil;
    self.tag = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
    ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
}

#pragma mark - Private methods

- (void)setupTableView {
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    TableViewCellConfigureBlock configureCellBlock = ^(PFCommonTableViewCell * cell, NSDictionary * post) {
        cell.titleLabel.text = [[post objectForKey:WP_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];
        NSDate * date = [NSDate pfDateFromIso8601String:[post objectForKey:WP_POST_DATE_KEY]];
        NSString * excerpt = [[post objectForKey:WP_POST_EXCERPT_KEY] pfStringByConvertingHTMLToPlainText];
        cell.descriptionLabel.text = [NSString stringWithFormat:@"%@\r\n\r\n%@", [NSString pfMediumDateStringFromDate:date], excerpt];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    TableViewCellSelectBlock selectCellBlock = ^(NSIndexPath * indexPath , NSDictionary * post) {
        // track selected post
        NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
        [self performSegueWithIdentifier:@"postsToPostDetailsSegue" sender:self];
    };
    
    self.posts = [NSArray array];
    self.postsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.posts
                                                          cellIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]
                                                      configureCellBlock:configureCellBlock
                                                         selectCellBlock:selectCellBlock];
    self.tableView.dataSource = self.postsArrayDataSource;
    self.tableView.delegate = self.postsArrayDataSource;
    
    // hide extra rows
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)fetchPosts {
    
    [self showBarberPole];
    
    @weakify(self)
    
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_DATE_KEY, WP_POST_EXCERPT_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];    // ID, title, date, URL
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[fields]
                                                            forKeys:@[WP_SEARCH_POSTS_API_FIELDS_KEY]];

    // add category and tag parameters as needed
    if ( self.category ) {
        NSString * categorySlug = [self.category objectForKey:WP_CATEGORY_SLUG_KEY];
        parameters = [NSDictionary dictionaryWithObjects:@[categorySlug, fields]
                                                 forKeys:@[WP_SEARCH_POSTS_API_CATEGORY_KEY, WP_SEARCH_POSTS_API_FIELDS_KEY]];
        
    } else if ( self.tag ) {
        NSString * tagSlug = [self.tag objectForKey:WP_TAG_SLUG_KEY];
        parameters = [NSDictionary dictionaryWithObjects:@[tagSlug, fields]
                                                 forKeys:@[WP_SEARCH_POSTS_API_TAG_KEY, WP_SEARCH_POSTS_API_FIELDS_KEY]];
    }
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostsWithParameters:parameters
                                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 @strongify(self)
                                                                 if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                                     NSDictionary * response = (NSDictionary *)responseObject;
                                                                     self->_posts = [response objectForKey:WP_POSTS_API_RESPONSE_POSTS_KEY];
                                                                     [self->_postsArrayDataSource reloadItems:self->_posts];
                                                                     [self->_tableView reloadData];
                                                                 }

                                                                 [self hideBarberPole];
                                                             }
                                                             failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                 [self hideBarberPole];
                                                             }];
}

@end
