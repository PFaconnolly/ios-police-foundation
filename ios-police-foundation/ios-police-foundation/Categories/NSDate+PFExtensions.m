//
//  NSDate+Extensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/14/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "NSDate+PFExtensions.h"

@implementation NSDate (PFExtensions)

+ (NSDate *)pfDateFromIso8601String:(NSString *)dateString {
    NSDateFormatter * iso8601DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [iso8601DateFormatter setLocale:enUSPOSIXLocale];
    [iso8601DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [iso8601DateFormatter dateFromString:dateString];
}

+ (NSDate *)pfDateFromRfc822String:(NSString *)dateString {
    NSDateFormatter * rfc822DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc822DateFormatter setLocale:enUSPOSIXLocale];
    [rfc822DateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z:00"];
    return [rfc822DateFormatter dateFromString:dateString];
}

@end
