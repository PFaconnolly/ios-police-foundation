//
//  PFCategoriesViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFRefreshableCollectionViewController.h"

@interface PFCategoriesViewController : PFRefreshableCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray * categories;

@end
