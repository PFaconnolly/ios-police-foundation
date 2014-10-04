//
//  PFTagCollectionViewCell.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/3/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFCollectionViewCell.h"

@interface PFTagCollectionViewCell : PFCollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel * nameLabel;
@property (strong, nonatomic) IBOutlet UILabel * descriptionLabel;

@end
