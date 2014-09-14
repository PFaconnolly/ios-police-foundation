//
//  PFCategoryTableViewCell.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFTableViewCell.h"

@interface PFCategoryTableViewCell : PFTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)setCategory:(NSDictionary *)category;

@end
