//
//  PFCategoryTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCategoryTableViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFCategoryTableViewCell()

@end

@implementation PFCategoryTableViewCell

- (void)setCategory:(NSDictionary *)category {
    self.categoryLabel.text = [category objectForKey:@"name"];
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@ posts - %@", [category objectForKey:@"post_count"], [category objectForKey:@"description"]];
}

@end
