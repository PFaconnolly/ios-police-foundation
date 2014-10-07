//
//  PFWelcomeViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWelcomeViewController.h"
#import "PFWelcomeCollectionViewCell.h"
#import "PFResearchCollectionViewCell.h"

@interface PFWelcomeViewController ()

@property (nonatomic, weak) id<PFWelcomeSelectorDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView * collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

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
    
    self.pageControl.numberOfPages = 2;
    
    [self.collectionView registerNib:[PFWelcomeCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFWelcomeCollectionViewCell pfCellReuseIdentifier]];
    [self.collectionView registerNib:[PFResearchCollectionViewCell pfNib] forCellWithReuseIdentifier:[PFResearchCollectionViewCell pfCellReuseIdentifier]];
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
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * cellReuseIdentifier = @"Cell";
    
    switch ( indexPath.row ) {
        case 0: cellReuseIdentifier = [PFWelcomeCollectionViewCell pfCellReuseIdentifier]; break;
        case 1: cellReuseIdentifier = [PFResearchCollectionViewCell pfCellReuseIdentifier]; break;
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
