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
#import "PFWelcomeDocumentsCollectionViewCell.h"

@interface PFWelcomeViewController ()

@property (nonatomic, weak) id<PFWelcomeSelectorDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView * collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl * pageControl;

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
    
    self.pageControl.numberOfPages = 6;
    
    [self.collectionView registerNib:[PFWelcomeCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeResearchCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeResearchCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeCategoriesCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeCategoriesCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeTagsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeTagsCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFWelcomeNewsCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeNewsCollectionViewCell pfCellReuseIdentifier]];
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
    return CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cellReuseIdentifier = @"Cell";
    
    switch ( indexPath.row ) {
        case 0: cellReuseIdentifier = [PFWelcomeCollectionViewCell pfCellReuseIdentifier]; break;
        case 1: cellReuseIdentifier = [PFWelcomeResearchCollectionViewCell pfCellReuseIdentifier]; break;
        case 2: cellReuseIdentifier = [PFWelcomeCategoriesCollectionViewCell pfCellReuseIdentifier]; break;
        case 3: cellReuseIdentifier = [PFWelcomeTagsCollectionViewCell pfCellReuseIdentifier]; break;
        case 4: cellReuseIdentifier = [PFWelcomeNewsCollectionViewCell pfCellReuseIdentifier]; break;
        case 5: cellReuseIdentifier = [PFWelcomeDocumentsCollectionViewCell pfCellReuseIdentifier]; break;
        default: break;
    }
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    self.pageControl.currentPage = indexPath.row;
    
    return cell;
}

#pragma mark - IBActions

- (IBAction)pageControlValueChanged:(id)sender {
    
}

- (IBAction)dismissButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)researchButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_Research];
    }
}

- (IBAction)newsButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_News];
    }
}

- (IBAction)aboutButtonTapped:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(startWithScreen:)] ) {
        [self.delegate startWithScreen:PFScreen_About];
    }
}

@end
