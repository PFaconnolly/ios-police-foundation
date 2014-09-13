 //
//  PFSearchViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFSearchViewController.h"
#import "PFArrayDataSource.h"
#import "PFPostTableViewCell.h"
#import "NSDate+PFExtensions.h"
#import "NSString+PFExtensions.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFPostDetailsViewController.h"
#import "PFAnalyticsManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFSearchViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) PFArrayDataSource * postsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView * tableView;
@property (strong, nonatomic) IBOutlet UITextField * searchTextField;
@property (strong, nonatomic) IBOutlet UIButton * searchButton;

@end

@implementation PFSearchViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    self.screenName = @"WordPress Search Screen";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchTextField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
    ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearSearch];
    return YES;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchTextField resignFirstResponder];

    [self performSegueWithIdentifier:@"searchToPostDetailsSegue" sender:self];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // track selected post
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
    
    // track selected post
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
}

#pragma mark - Private methods

- (void)clearSearch {
    [self.searchTextField resignFirstResponder];
    self.posts = nil;
    [self.postsArrayDataSource reloadItems:self.posts];
    [self.tableView reloadData];
}

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFPostTableViewCell * cell, NSDictionary * category) {
        cell.titleLabel.text = [category objectForKey:WP_POST_TITLE_KEY];
        NSDate * date = [NSDate pfDateFromIso8601String:[category objectForKey:WP_POST_DATE_KEY]];
        cell.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.posts = [NSArray array];
    self.postsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.posts
                                                          cellIdentifier:@"Cell"
                                                      configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.postsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFPostTableViewCell nib] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = 70;
}

- (void)searchPosts {
    [self showBarberPole];
    
    NSString * searchString = self.searchTextField.text;
    
    if ( searchString == nil || searchString.length == 0 ) {
        [UIAlertView showWithTitle:@"Search failed" message:@"You did not enter any search terms."];
        [self hideBarberPole];
        return;
    }
    
    NSInteger numberOfResults = 20;
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_DATE_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];    // ID, title, date, URL
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[searchString, @(numberOfResults), fields]
                                                            forKeys:@[WP_SEARCH_POSTS_API_SEARCH_KEY, WP_SEARCH_POSTS_API_NUMBER_OF_RESULTS_KEY, WP_SEARCH_POSTS_API_FIELDS_KEY]];
    @weakify(self)
    
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
                                                                 [UIAlertView showWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                 [self hideBarberPole];
                                                             }];
}

- (void)doneButtonTapped:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)searchButtonTapped:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self searchPosts];
}

@end
