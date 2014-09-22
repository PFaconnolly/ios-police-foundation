//
//  PFCommonTableViewCell.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/21/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFCommonTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * descriptionLabel;

- (void)updateFonts;

@end
