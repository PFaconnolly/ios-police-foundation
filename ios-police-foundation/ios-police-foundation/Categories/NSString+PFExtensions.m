//
//  NSString+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "NSString+PFExtensions.h"

@implementation NSString (PFExtensions)

- (NSString *) pfStringByAppendingQueryStringParameters:(NSDictionary *)parameters {
    if ( parameters ) {
        __block NSString * queryParameters = [NSString string];
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL __unused *stop) {
            queryParameters = [queryParameters stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, obj]];
        }];
        // Replace first '&' with '?' and add parameters to url
        queryParameters = [queryParameters stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
        return [self stringByAppendingString:queryParameters];
    }
    return self;
}

@end
