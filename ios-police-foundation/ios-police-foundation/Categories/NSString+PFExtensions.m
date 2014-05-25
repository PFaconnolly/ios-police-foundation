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
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL __unused *stop) {
            
            NSString * objString = [NSString string];
            
            // assuming obj is of type NSString or NSArray (could be numbers and booleans at some point too)
            if ( [obj isKindOfClass:([NSString class])] ) {
                objString = [((NSString *)obj) pfURLEncodedString];
            } else if ( [obj isKindOfClass:([NSArray class])] ) {
                // join by comma, remove spaces
                objString = [[((NSArray *)obj) componentsJoinedByString:@","] stringByReplacingOccurrencesOfString:@" " withString:@""];
            }            
            queryParameters = [queryParameters stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, objString]];
        }];
        // Replace first '&' with '?' and add parameters to url
        queryParameters = [queryParameters stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
        return [self stringByAppendingString:queryParameters];
    }
    return self;
}

- (NSString *) pfURLEncodedString {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
