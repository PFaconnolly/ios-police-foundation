//
//  PFTagTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTagTableViewCell.h"

@implementation PFTagTableViewCell

- (void)setTagData:(NSDictionary *)tag {
    self.tagLabel.text = [tag objectForKey:@"name"];
    self.descriptionLabel.text = [tag objectForKey:@"description"];    
}

@end
