//
//  PFRefreshableCollectionViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 1/24/15.
//  Copyright (c) 2015 Police Foundation. All rights reserved.
//

#import "PFRefreshableCollectionViewController.h"

@interface PFRefreshableCollectionViewController ()

@property (nonatomic) UICollectionView * collectionView;

@end

@implementation PFRefreshableCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewControllerWillChangeToOrientation:(PFViewControllerOrientation)orientation {
    [super viewControllerWillChangeToOrientation:orientation];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionView.collectionViewLayout;
    [flowLayout invalidateLayout];
}

@end
