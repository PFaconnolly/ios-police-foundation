 //
//  PFSearchViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFSearchViewController.h"
#import "PFArrayDataSource.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFPostDetailsViewController.h"
#import "PFAnalyticsManager.h"
#import "PFArticleCollectionViewCell.h"
#import "PFPost.h"

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

@interface PFSearchViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) IBOutlet UITextField * searchTextField;
@property (strong, nonatomic) IBOutlet UIButton * searchButton;
@property (strong, nonatomic) IBOutlet UICollectionView * collectionView;
@property (strong, nonatomic) UILabel * noResultsLabel;

@end

@implementation PFSearchViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find Articles";
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    [self setUpCollectionView];
    
    self.searchButton.tintColor = [UIColor whiteColor];
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
    // track selected post and seque to post details
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    PFPost * post = [self.posts objectAtIndex:selectedIndexPath.row];
    NSString * postURL = post.link;
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
    NSString * postId = [NSString stringWithFormat:@"%lu", (unsigned long)post.postId];
    ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
}


#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat widthFactor = 0.5f;
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        widthFactor = 0.25f;
    }
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.collectionView.frame) * widthFactor, 200.0f);
    return size;
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFArticleCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PFArticleCollectionViewCell pfCellReuseIdentifier] forIndexPath:indexPath];
    
    // configure cell
    PFPost * post = [self.posts objectAtIndex:indexPath.row];
    cell.titleLabel.text = post.title;
    cell.dateLabel.text = [NSString pfMediumDateStringFromDate:post.date];
    cell.excerptLabel.text = post.excerpt;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchTextField resignFirstResponder];
    [self performSegueWithIdentifier:@"searchToPostDetailsSegue" sender:self];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearSearch];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchPosts];
    return YES;
}


#pragma mark - Private methods

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PFArticleCollectionViewCell pfNib]
          forCellWithReuseIdentifier:[PFArticleCollectionViewCell pfCellReuseIdentifier]];
    
    self.noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.noResultsLabel.text = @"No results found.";
    self.noResultsLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20.0];
    [self.noResultsLabel sizeToFit];
    self.noResultsLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(self.collectionView.frame) + 30);
}

- (void)clearSearch {
    [self.searchTextField resignFirstResponder];
    self.posts = nil;
    [self.collectionView reloadData];
}

- (void)searchPosts {
    [self showBarberPole];
    
    NSString * searchString = self.searchTextField.text;
    
    if ( searchString == nil || searchString.length == 0 ) {
        [UIAlertView pfShowWithTitle:@"Search failed" message:@"You did not enter any search terms."];
        [self hideBarberPole];
        return;
    }
    
    // track search
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_TEXT_SEARCH_ACTION label:searchString value:nil];
    
    NSInteger numberOfResults = 20;
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_EXCERPT_KEY, WP_POST_DATE_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[searchString, @(numberOfResults), fields]
                                                            forKeys:@[WP_SEARCH_POSTS_API_SEARCH_KEY, WP_SEARCH_POSTS_API_NUMBER_OF_RESULTS_KEY, WP_SEARCH_POSTS_API_FIELDS_KEY]];
    @weakify(self)
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostsWithParameters:parameters
                                                             successBlock:^(AFHTTPRequestOperation *operation, NSArray * posts) {
                                                                 @strongify(self)
                                                                 self->_posts = posts;
                                                                 [self->_collectionView reloadData];
                                                                 
                                                                 // add no results label
                                                                 if ( self->_posts == nil || self->_posts.count == 0 ) {
                                                                     [self->_collectionView addSubview:self->_noResultsLabel];
                                                                 } else {
                                                                     [self->_noResultsLabel removeFromSuperview];
                                                                 }
                                                                 
                                                                 [self hideBarberPole];
                                                             }
                                                             failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                 [self hideBarberPole];
                                                             }];
}

- (void)doneButtonTapped:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchButtonTapped:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self searchPosts];
}

@end
