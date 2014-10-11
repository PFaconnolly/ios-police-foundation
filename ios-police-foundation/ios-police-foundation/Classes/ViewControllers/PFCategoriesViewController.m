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
#import "PFWordPressCategory.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFCategoriesViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PFCategoriesViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpCollectionView];
    
    // If categories are nil, fetch them from the server.
    // Otherwise assume that we're displaying a provided
    // set of categories.
    if ( self.categories == nil ) {
        self.title = @"Categories";

        [self fetchCategories];
        
        @weakify(self);
        self.refreshBlock = ^(){
            @strongify(self);
            [self fetchCategories];
        };
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"WordPress Categories Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    PFWordPressCategory * category = [self.categories objectAtIndex:selectedIndexPath.row];
    
    if ( [segue.identifier isEqualToString:@"categoriesToPostsSegue"] ) {
        // set category on posts view controller
        ((PFPostsViewController *)segue.destinationViewController).category = category;
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
    PFWordPressCategory * category = [self.categories objectAtIndex:indexPath.row];
    cell.nameLabel.text =  category.name;
    cell.descriptionLabel.text = category.summary;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // track selected category
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    PFWordPressCategory * category = [self.categories objectAtIndex:selectedIndexPath.row];
    NSString * selectedCategorySlug = category.slug;
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_ACTION label:selectedCategorySlug value:nil];
    
    if ( category.subCategories != nil && category.subCategories.count > 0 ) {
        /* The selected Category has sub categories so push another instance of this 
         same categories view controller onto the stack, but give it the sub categories
         to display which will disable the fetch from the server and override the view
         controller's title. */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle: nil];
        PFCategoriesViewController * subCategoriesViewController = [storyboard instantiateViewControllerWithIdentifier:@"PFCategoriesViewController"];
        subCategoriesViewController.categories = category.subCategories;
        subCategoriesViewController.title = category.name;
        
        [self.navigationController pushViewController:subCategoriesViewController animated:YES];
        
    } else {
        [self performSegueWithIdentifier:@"categoriesToPostsSegue" sender:self];
    }
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
                                                                  successBlock:^(AFHTTPRequestOperation *operation, NSArray * categories) {
                                                                      @strongify(self)
                                                                      self->_categories = categories;
                                                                      [self->_collectionView reloadData];
                                                                      [self hideBarberPole];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                      [self hideBarberPole];
                                                                  }];
}

@end







