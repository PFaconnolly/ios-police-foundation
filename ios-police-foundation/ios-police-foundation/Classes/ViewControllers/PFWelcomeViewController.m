//
//  PFWelcomeViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWelcomeViewController.h"
#import "PFWelcomeCollectionViewCell.h"
#import "PFWelcomeResearchCollectionViewCell.h"
#import "PFWelcomeCategoriesCollectionViewCell.h"
#import "PFWelcomeTagsCollectionViewCell.h"
#import "PFWelcomeNewsCollectionViewCell.h"
#import "PFWelcomeTermsCollectionViewCell.h"
#import "PFWelcomeDocumentsCollectionViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFWelcomeViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) id<PFWelcomeSelectorDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView * collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl * pageControl;
@property (assign, nonatomic, getter=isScrolling) BOOL scrolling;

@end

@implementation PFWelcomeViewController

- (id)initWithDelegate:(id<PFWelcomeSelectorDelegate>)delegate {
    NSString * nibName = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"PFWelcomeViewController" : @"PFWelcomeViewController~iPad";
    self = [super initWithNibName:nibName bundle:nil];
    if ( self != nil ) {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageControl.numberOfPages = 7;

    [self.collectionView registerNib:[PFWelcomeCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeResearchCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeResearchCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeCategoriesCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeCategoriesCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeTagsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeTagsCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeNewsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeNewsCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeTermsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeTermsCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeDocumentsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeDocumentsCollectionViewCell pfCellReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Welcome Screen";
}

// only supports portrait interface orienation
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellReuseIdentifier = @"Cell";
    NSString * analyticsActionName = GA_VIEWED_WELCOME_INSTRUCTIONS_ACTION;
    
    switch ( indexPath.row ) {
        case 0: {
            cellReuseIdentifier = [PFWelcomeCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_WELCOME_INSTRUCTIONS_ACTION;
            break;
        }
        case 1: {
            cellReuseIdentifier = [PFWelcomeResearchCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_RESEARCH_INSTRUCTIONS_ACTION;
            break;
        }
        case 2: {
            cellReuseIdentifier = [PFWelcomeCategoriesCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_CATEGORIES_INSTRUCTIONS_ACTION;
            break;
        }
        case 3: {
            cellReuseIdentifier = [PFWelcomeTagsCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_TAGS_INSTRUCTIONS_ACTION;
            break;
        }
        case 4: {
            cellReuseIdentifier = [PFWelcomeNewsCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_NEWS_INSTRUCTIONS_ACTION;
            break;
        }
        case 5: {
            cellReuseIdentifier = [PFWelcomeTermsCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_TERMS_INSTRUCTIONS_ACTION;
            break;
        }
        case 6: {
            cellReuseIdentifier = [PFWelcomeDocumentsCollectionViewCell pfCellReuseIdentifier];
            analyticsActionName = GA_VIEWED_DOCUMENTS_INSTRUCTIONS_ACTION;
            break;
        }
        default: break;
    }
    
    // track the welcome screen cell that was viewed
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:analyticsActionName label:nil value:nil];
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)tcUnused {
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}


#pragma mark - IBActions

- (IBAction)dismissButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
