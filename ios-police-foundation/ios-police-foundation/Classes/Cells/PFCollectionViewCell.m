//
//  PFCollectionViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCollectionViewCell.h"
#import "UIColor+PFExtensions.h"

@implementation PFCollectionViewCell

- (void)awakeFromNib {

    self.backgroundColor = [UIColor pfRandomLightBlueColor];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 0.5f;
    
    // iOS 8 encoded collection view cells don't have auto resizing masks by default:
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

@end
