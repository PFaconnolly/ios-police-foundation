//
//  PFCollectionViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCollectionViewCell.h"

@implementation PFCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

@end
