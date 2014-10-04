//
//  PFArticleCollectionViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFArticleCollectionViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation PFArticleCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1.0f;
    
    // iOS 8 encoded collection view cells don't have auto resizing masks by default:
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;}

@end
