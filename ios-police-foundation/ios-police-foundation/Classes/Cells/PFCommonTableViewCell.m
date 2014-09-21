//
//  PFCommonTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/21/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCommonTableViewCell.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f

@interface PFCommonTableViewCell()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PFCommonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [UILabel newAutoLayoutView];
        [self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        
        self.descriptionLabel = [UILabel newAutoLayoutView];
        [self.descriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.descriptionLabel setNumberOfLines:0];
        [self.descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [self.descriptionLabel setTextColor:[UIColor darkGrayColor]];
 
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descriptionLabel];
        
        [self updateFonts];
    }
    
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) {
        return;
    }
    
    // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
    // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
    //      See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
    // self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
    
    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    
    // This is the constraint that connects the title and body labels. It is a "greater than or equal" inequality so that if the row height is
    // slightly larger than what is actually required to fit the cell's subviews, the extra space will go here. (This is the case on iOS 7
    // where the cell separator is only 0.5 points tall, but in the tableView:heightForRowAtIndexPath: method of the view controller, we add
    // a full 1.0 point in extra height to account for it, which results in 0.5 points extra space in the cell.)
    // See https://github.com/smileyborg/TableViewCellWithAutoLayout/issues/3 for more info.
    [self.descriptionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    
    [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [self.descriptionLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    
    self.didSetupConstraints = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line descriptionLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
}

- (void)updateFonts
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

@end
