//
//  UIAlertView+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/23/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UIAlertView+PFExtensions.h"

@implementation UIAlertView (PFExtensions)

+ (void)showWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
