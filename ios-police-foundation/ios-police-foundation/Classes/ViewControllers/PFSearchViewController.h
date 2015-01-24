//
//  PFSearchViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFRefreshableCollectionViewController.h"

@interface PFSearchViewController : PFRefreshableCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@end
