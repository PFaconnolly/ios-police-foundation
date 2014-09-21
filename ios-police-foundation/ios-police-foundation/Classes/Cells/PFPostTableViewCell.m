//
//  PFPostTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostTableViewCell.h"

@implementation PFPostTableViewCell

- (void)setPost:(NSDictionary *)post {
    self.titleLabel.text = [post objectForKey:WP_POST_TITLE_KEY];
    NSDate * date = [NSDate pfDateFromIso8601String:[post objectForKey:WP_POST_DATE_KEY]];
    self.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
}

@end
