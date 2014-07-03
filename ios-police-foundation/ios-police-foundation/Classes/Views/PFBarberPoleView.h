//
//  PFBarberPoleView.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/30/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFBarberPoleView : UIView

#pragma mark UIView Appearance Properties

/*!
 @property  backgroundColor
 @abstract  The receiver's background color.
 */
@property (nonatomic, copy) UIColor * backgroundColor UI_APPEARANCE_SELECTOR;

#pragma mark TCBarberPoleView Appearance Properties

/*!
 @property  stripeWidth
 @abstract  The receiver's stripe width.
 */
@property (nonatomic, assign) CGFloat stripeWidth UI_APPEARANCE_SELECTOR;

/*!
 @property  stripeGap
 @abstract  The receiver's stripe gap.
 */
@property (nonatomic, assign) CGFloat stripeGap UI_APPEARANCE_SELECTOR;

/*!
 @property  stripeColor
 @abstract  The receiver's stripe color.
 */
@property (nonatomic, strong) UIColor * stripeColor UI_APPEARANCE_SELECTOR;

@end
