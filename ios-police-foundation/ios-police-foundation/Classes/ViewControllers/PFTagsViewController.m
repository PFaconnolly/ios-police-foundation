//
//  PFTagsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTagsViewController.h"
#import "PFAppDelegate.h"
#import "PFArrayDataSource.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFBarberPoleView.h"
#import "PFAnalyticsManager.h"
#import "PFPostsViewController.h"
#import "PFTagCollectionViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFTagsViewController ()

@property (strong, nonatomic) NSArray * tags;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PFTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tags";

    [self setUpCollectionView];
    
    [self fetchTags];
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchTags];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];  
    self.screenName = @"WordPress Tags Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // track selected tag
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    NSDictionary * tag = [self.tags objectAtIndex:selectedIndexPath.row];
    NSString * selectedTagSlug = [tag objectForKey:WP_TAG_SLUG_KEY];
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_TAG_ACTION label:selectedTagSlug value:nil];
    
    // segue to posts with the provided tag
    ((PFPostsViewController *)segue.destinationViewController).tag = tag;
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
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFTagCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PFTagCollectionViewCell pfCellReuseIdentifier] forIndexPath:indexPath];
    
    // configure cell
    NSDictionary * tag = [self.tags objectAtIndex:indexPath.row];
    cell.nameLabel.text =  [tag valueForKey:WP_TAG_NAME_KEY];
    cell.descriptionLabel.text = [tag valueForKey:WP_TAG_DESCRIPTION_KEY];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    // segue to posts
    [self performSegueWithIdentifier:@"tagsToPostsSegue" sender:self];
}



#pragma mark - Private methods

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PFTagCollectionViewCell pfNib]
          forCellWithReuseIdentifier:[PFTagCollectionViewCell pfCellReuseIdentifier]];
}

- (void)fetchTags {
    [self showBarberPole];
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getTagsWithParameters:nil
                                                            successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                @strongify(self)
                                                                NSDictionary * response = (NSDictionary *)responseObject;
                                                                self->_tags = [response objectForKey:WP_TAGS_KEY];
                                                                [self->_collectionView reloadData];                                                                
                                                                [self hideBarberPole];
                                                            }
                                                            failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                [self hideBarberPole];
                                                            }];
}

@end
