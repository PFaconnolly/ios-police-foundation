//
//  PFResearchViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFResearchViewController.h"
#import "PFCommonTableViewCell.h"
#import "PFAnalyticsManager.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFPostDetailsViewController.h"
#import "PFArticleCollectionViewCell.h"

// testing
#import "PFWelcomeViewController.h"

typedef void (^TableViewCellConfigureBlock)(id cell, id indexPath);
typedef void (^TableViewCellSelectBlock)(id indexPath);

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFResearchViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PFResearchViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpCollectionView];
    [self fetchPosts];
    
    UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonTapped:)];
    UIBarButtonItem * categoriesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Categories Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(categoriesButtonTapped:)];
    UIBarButtonItem * tagsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Tags Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(tagsButtonTapped:)];
    self.navigationItem.leftBarButtonItems = @[searchButton, categoriesButton, tagsButton];
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchPosts];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"WordPress Research Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"researchToPostDetailsSegue"] ) {
        // track selected post and seque to post details
        NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
        NSDictionary * post = [self.posts objectAtIndex:selectedIndexPath.row];
        NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
        
        NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
        ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
    }
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
    [self performSegueWithIdentifier:@"researchToPostDetailsSegue" sender:self];
}

#pragma mark - Private methods

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PFArticleCollectionViewCell pfNib]
          forCellWithReuseIdentifier:[PFArticleCollectionViewCell pfCellReuseIdentifier]];
}

- (void)fetchPosts {
    [self showBarberPole];
    
    @weakify(self)
    
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_EXCERPT_KEY, WP_POST_DATE_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];    // ID, title, date, URL
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[fields, @(14), @"DESC"]
                                                            forKeys:@[WP_SEARCH_POSTS_API_FIELDS_KEY, WP_SEARCH_POSTS_API_NUMBER_OF_RESULTS_KEY, WP_SEARCH_POSTS_API_ORDER_KEY]];
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

- (void)searchButtonTapped:(id)sender {
    PFWelcomeViewController * welcomeVC = [[PFWelcomeViewController alloc] initWithDelegate:nil];
    [self presentViewController:welcomeVC animated:YES completion:nil];
    
    //[self performSegueWithIdentifier:@"presentSearchSegue" sender:self];
}

- (void)categoriesButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"researchToCategoriesSegue" sender:self];
}

- (void)tagsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"researchToTagsSegue" sender:self];
}

@end
