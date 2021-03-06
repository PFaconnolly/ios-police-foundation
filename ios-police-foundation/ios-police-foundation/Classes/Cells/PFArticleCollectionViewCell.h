//
//  PFArticleCollectionViewCell.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFBorderedCollectionViewCell.h"

@interface PFArticleCollectionViewCell : PFBorderedCollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;
@property (strong, nonatomic) IBOutlet UILabel * excerptLabel;

@end
