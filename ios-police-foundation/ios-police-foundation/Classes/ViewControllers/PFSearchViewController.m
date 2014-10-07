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

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFSearchViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) IBOutlet UITextField * searchTextField;
@property (strong, nonatomic) IBOutlet UIButton * searchButton;
@property (strong, nonatomic) IBOutlet UICollectionView * collectionView;

@end

@implementation PFSearchViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find Articles";
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    [self setUpCollectionView];
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
    // track selected post
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    NSDictionary * post = [self.posts objectAtIndex:selectedIndexPath.row];
    NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
    
    // segue to post details
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
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
    NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
    cell.titleLabel.text = [[post objectForKey:WP_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];
    NSDate * date = [NSDate pfDateFromIso8601String:[post objectForKey:WP_POST_DATE_KEY]];
    NSString * excerpt = [[post objectForKey:WP_POST_EXCERPT_KEY] pfStringByConvertingHTMLToPlainText];
    cell.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
    cell.excerptLabel.text = excerpt;
    
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
                                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 @strongify(self)
                                                                 if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                                     NSDictionary * response = (NSDictionary *)responseObject;
                                                                     self->_posts = [response objectForKey:WP_POSTS_API_RESPONSE_POSTS_KEY];
                                                                     [self->_collectionView reloadData];
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
