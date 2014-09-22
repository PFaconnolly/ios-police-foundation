//
//  UITableViewCell+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (PFExtensions)

+ (UINib*)pfNib;
+ (NSString *)pfCellReuseIdentifier;

- (CGFloat)pfGetCellHeightForTableView:(UITableView *)tableView;

@end
