//
//  PFBorderedCollectionViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/7/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFBorderedCollectionViewCell.h"
#import "UIColor+PFExtensions.h"

@implementation PFBorderedCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor pfRandomLightBlueColor];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 0.5f;
}

@end
