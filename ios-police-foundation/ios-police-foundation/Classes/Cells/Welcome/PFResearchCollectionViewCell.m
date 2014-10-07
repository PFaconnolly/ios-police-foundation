//
//  PFResearchCollectionViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/6/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFResearchCollectionViewCell.h"

@implementation PFResearchCollectionViewCell

- (void)awakeFromNib {    
    // iOS 8 encoded collection view cells don't have auto resizing masks by default:
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

@end
