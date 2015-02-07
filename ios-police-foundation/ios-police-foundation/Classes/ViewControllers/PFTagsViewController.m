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
#import "PFWordPRessTag.h"

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

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
    PFWordPressTag * tag = [self.tags objectAtIndex:selectedIndexPath.row];
    NSString * selectedTagSlug = tag.slug;
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_TAG_ACTION label:selectedTagSlug value:nil];
    
    // segue to posts with the provided tag
    ((PFPostsViewController *)segue.destinationViewController).tag = tag;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // width factor is how wide each cell should be
    // by default it should be half the size of the screen
    CGFloat widthFactor = IPHONE_COLLECTION_VIEW_CELL_WIDTH_FACTOR;
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        widthFactor = IPAD_COLLECTION_VIEW_CELL_WIDTH_FACTOR;
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
    PFWordPressTag * tag = [self.tags objectAtIndex:indexPath.row];
    cell.nameLabel.text =  tag.name;
    cell.descriptionLabel.text = tag.summary;
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
                                                            successBlock:^(AFHTTPRequestOperation * operation, NSArray * tags) {
                                                                @strongify(self)
                                                                self->_tags = tags;
                                                                [self->_collectionView reloadData];                                                                
                                                                [self hideBarberPole];
                                                            }
                                                            failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                [self hideBarberPole];
                                                            }];
}

@end
