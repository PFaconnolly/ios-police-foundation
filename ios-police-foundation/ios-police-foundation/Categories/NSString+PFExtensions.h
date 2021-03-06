//
//  NSString+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PFExtensions)

+ (NSString *) pfFullDateStringFromDate:(NSDate *)date;
+ (NSString *) pfMediumDateStringFromDate:(NSDate *)date;
+ (NSString *) pfShortDateStringFromDate:(NSDate *)date;
+ (NSString *) pfStyledHTMLDocumentWithTitle:(NSString *)title date:(NSString*)date body:(NSString *)body;

- (NSString *) pfStringByAppendingQueryStringParameters:(NSDictionary *)parameters;
- (NSString *) pfURLEncodedString;
- (NSString *) pfStringByConvertingHTMLToPlainText;

@end
