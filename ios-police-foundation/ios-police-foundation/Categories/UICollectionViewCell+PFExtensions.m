//
//  UICollectionViewCell+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UICollectionViewCell+PFExtensions.h"

@implementation UICollectionViewCell (PFExtensions)

+ (UINib *)pfNib {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

+ (NSString *)pfCellReuseIdentifier {
    return NSStringFromClass(self.class);
}

@end
