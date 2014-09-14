//
//  UITableViewCell+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UITableViewCell+PFExtensions.h"

@implementation UITableViewCell (PFExtensions)

+ (UINib *)pfNib {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

+ (NSString *)pfCellReuseIdentifier {
    return NSStringFromClass(self.class);
}

- (CGFloat)pfGetCellHeightForTableView:(UITableView *)tableView {
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.bounds));
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end
