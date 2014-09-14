//
//  PFTagTableViewCell.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFTableViewCell.h"

@interface PFTagTableViewCell : PFTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
