//
//  NSDate+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/14/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PFExtensions)

+ (NSDate *)pfDateFromIso8601String:(NSString *)dateString;

@end
