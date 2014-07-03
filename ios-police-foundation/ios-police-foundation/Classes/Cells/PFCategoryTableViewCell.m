//
//  PFCategoryTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCategoryTableViewCell.h"

@interface PFCategoryTableViewCell()

@property (strong, nonatomic) IBOutlet UIView *postCountView;

@end

@implementation PFCategoryTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:@"PFCategoryTableViewCell" bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.postCountView.layer.cornerRadius = 4.0f;
}

- (void)setCategory:(NSDictionary *)category {
    self.categoryLabel.text = [category objectForKey:@"name"];
    self.descriptionLabel.text = [category objectForKey:@"description"];
    self.postCountLabel.text = [NSString stringWithFormat:@"%@", [category objectForKey:@"post_count"]];
    [self.postCountLabel sizeToFit];
}

@end
