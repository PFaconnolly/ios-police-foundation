//
//  UICollectionView+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/6/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UICollectionView+PFExtensions.h"
#import "UIColor+PFExtensions.h"

@implementation UICollectionView (PFExtensions)

- (void)awakeFromNib {
    self.backgroundColor = [UIColor pfLightBlueColor];
}

@end
