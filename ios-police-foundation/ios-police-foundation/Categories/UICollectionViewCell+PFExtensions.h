//
//  UICollectionViewCell+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell (PFExtensions)

+ (UINib*)pfNib;
+ (NSString *)pfCellReuseIdentifier;

@end
