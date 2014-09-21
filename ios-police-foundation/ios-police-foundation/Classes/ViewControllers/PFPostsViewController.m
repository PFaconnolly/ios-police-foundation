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
#import "PFPostTableViewCell.h"
#import "PFPostDetailsViewController.h"
#import "PFBarberPoleView.h"
#import "PFAnalyticsManager.h"

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.screenName = @"WordPress Post List Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
    ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Dynamic height table cells in iOS 8 need only an estimated row height
    // and the UITableViewAutomaticDimension specified. iOS 7 and below need a
    // prototype cell
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        return UITableViewAutomaticDimension;
    }
    
    PFPostTableViewCell * prototypeCell = (PFPostTableViewCell *)[PFPostTableViewCell prototypeCell];
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:indexPath];
    [prototypeCell setPost:post];
    
    CGFloat height = [prototypeCell pfGetCellHeightForTableView:tableView];
    DDLogVerbose(@"row: %li height: %f", (long)indexPath.row, height);
    DDLogVerbose(@"-");
    DDLogVerbose(@"-");
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"postsToPostDetailsSegue" sender:self];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // track selected post
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
    
    // track selected post
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
}

#pragma mark - Private methods

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFPostTableViewCell * cell, NSDictionary * post) {
        cell.titleLabel.text = [post objectForKey:WP_POST_TITLE_KEY];
        NSDate * date = [NSDate pfDateFromIso8601String:[post objectForKey:WP_POST_DATE_KEY]];
        cell.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.posts = [NSArray array];
    self.postsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.posts
                                                          cellIdentifier:[PFPostTableViewCell pfCellReuseIdentifier]
                                                      configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.postsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFPostTableViewCell pfNib] forCellReuseIdentifier:[PFPostTableViewCell pfCellReuseIdentifier]];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)fetchPosts {
    
    [self showBarberPole];
    
    @weakify(self)
    
    NSString * category = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug;
    NSString * tag = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedTagSlug;
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_DATE_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];    // ID, title, date, URL
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[category, tag, fields]
                                                            forKeys:@[WP_SEARCH_POSTS_API_CATEGORY_KEY, WP_SEARCH_POSTS_API_TAG_KEY, WP_SEARCH_POSTS_API_FIELDS_KEY]];
    
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
