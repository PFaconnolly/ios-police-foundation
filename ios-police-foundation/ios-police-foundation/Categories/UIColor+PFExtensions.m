//
//  UIColor+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/4/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "UIColor+PFExtensions.h"

@implementation UIColor (PFExtensions)

+ (UIColor *)pfLightBlueColor {
    CGFloat max = 255.0f;
    return [UIColor colorWithRed:245/max green:252/max blue:255/max alpha:1.0f];
}

+ (UIColor *)pfRandomLightBlueColor {
    
    /*
    237/250/255
    233/243/247
    230/248/255
    222/246/255
    211/233/242
    211/235/245
    200/234/247
    209/242/255
     */
    
    CGFloat max = 255.0f;
    
    NSArray * colors = @[[UIColor colorWithRed:237/max green:250/max blue:255/max alpha:1.0f],
                         [UIColor colorWithRed:233/max green:243/max blue:247/max alpha:1.0f],
                         [UIColor colorWithRed:230/max green:248/max blue:255/max alpha:1.0f],
                         [UIColor colorWithRed:222/max green:246/max blue:255/max alpha:1.0f],
                         [UIColor colorWithRed:211/max green:233/max blue:242/max alpha:1.0f],
                         [UIColor colorWithRed:211/max green:235/max blue:245/max alpha:1.0f],
                         [UIColor colorWithRed:200/max green:234/max blue:247/max alpha:1.0f],
                         [UIColor colorWithRed:209/max green:242/max blue:255/max alpha:1.0f]];
    
    NSInteger r = arc4random_uniform(8);

    return colors[r];
}

+ (UIColor *)pfRandomLightGrayColor {
    return nil;
}

@end
