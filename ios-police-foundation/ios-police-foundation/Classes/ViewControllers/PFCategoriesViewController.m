//
//  PFCategoriesViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCategoriesViewController.h"
#import "PFAppDelegate.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFArrayDataSource.h"
#import "PFBarberPoleView.h"
#import "PFAnalyticsManager.h"
#import "PFPostsViewController.h"
#import "PFCategoryCollectionViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFCategoriesViewController ()

@property (strong, nonatomic) NSArray * categories;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PFCategoriesViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Categories";
    [self setUpCollectionView];
    [self fetchCategories];

    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchCategories];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"WordPress Categories Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // track selected category
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    NSDictionary * category = [self.categories objectAtIndex:selectedIndexPath.row];
    NSString * selectedCategorySlug = [category objectForKey:WP_CATEGORY_SLUG_KEY];
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_ACTION label:selectedCategorySlug value:nil];
    
    // set category on posts view controller
    ((PFPostsViewController *)segue.destinationViewController).category = category;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat widthFactor = 0.5f;
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        widthFactor = 0.25f;
    }
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.collectionView.frame) * widthFactor, 150.0f);
    return size;
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFCategoryCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PFCategoryCollectionViewCell pfCellReuseIdentifier] forIndexPath:indexPath];
    
    // configure cell
    NSDictionary * category = [self.categories objectAtIndex:indexPath.row];
    cell.nameLabel.text =  [category valueForKey:WP_CATEGORY_NAME_KEY];
    cell.descriptionLabel.text = [category valueForKey:WP_CATEGORY_DESCRIPTION_KEY];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"categoriesToPostsSegue" sender:self];
}




#pragma mark - Private methods

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PFCategoryCollectionViewCell pfNib]
          forCellWithReuseIdentifier:[PFCategoryCollectionViewCell pfCellReuseIdentifier]];
}

- (void)fetchCategories {
    [self showBarberPole];
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getCategoriesWithParameters:nil
                                                                  successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      @strongify(self)
                                                                      NSDictionary * response = (NSDictionary *)responseObject;
                                                                      self->_categories = [response objectForKey:WP_CATEGORIES_KEY];
                                                                      [self->_collectionView reloadData];
                                                                      [self hideBarberPole];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                      [self hideBarberPole];
                                                                  }];
}

@end

