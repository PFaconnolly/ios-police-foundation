//
//  NSString+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PFExtensions)

- (NSString *) pfStringByAppendingQueryStringParameters:(NSDictionary *)parameters;

@end
