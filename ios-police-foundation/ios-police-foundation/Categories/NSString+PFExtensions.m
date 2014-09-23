//
//  NSString+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "NSString+PFExtensions.h"
#import "GTMNSString+HTML.h"

@implementation NSString (PFExtensions)

+ (NSString *) pfFullDateStringFromDate:(NSDate *)date {
    NSDateFormatter * displayDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [displayDateFormatter setLocale:enUSPOSIXLocale];
    [displayDateFormatter setDateStyle:NSDateFormatterFullStyle];
    [displayDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [displayDateFormatter stringFromDate:date];
}

+ (NSString *) pfMediumDateStringFromDate:(NSDate *)date {
    NSDateFormatter * displayDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [displayDateFormatter setLocale:enUSPOSIXLocale];
    [displayDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [displayDateFormatter stringFromDate:date];
}

+ (NSString *) pfShortDateStringFromDate:(NSDate *)date {
    NSDateFormatter * displayDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [displayDateFormatter setLocale:enUSPOSIXLocale];
    [displayDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [displayDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [displayDateFormatter stringFromDate:date];
}

+ (NSString *) pfStyledHTMLDocumentWithBodyContent:(NSString *)content {
    NSString * html = [NSString stringWithFormat:@"<html>" \
                            "<head>" \
                                "<link href=\"default.css\" rel=\"stylesheet\" type=\"text/css\" />" \
                            "</head>" \
                            "<body>%@</body>" \
                       "</html>", content];
    return html;
}

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

- (NSString *) pfStringByConvertingHTMLToPlainText {
    @autoreleasepool {
        
        // Character sets
        NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        
        // Scan and find all tags
        NSMutableString *result = [[NSMutableString alloc] initWithCapacity:self.length];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:self];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setCaseSensitive:YES];
        NSString *str = nil, *tagName = nil;
        BOOL dontReplaceTagWithSpace = NO;
        do {
            
            // Scan up to the start of a tag or whitespace
            if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
                [result appendString:str];
                str = nil; // reset
            }
            
            // Check if we've stopped at a tag/comment or whitespace
            if ([scanner scanString:@"<" intoString:NULL]) {
                
                // Stopped at a comment, script tag, or other tag
                if ([scanner scanString:@"!--" intoString:NULL]) {
                    
                    // Comment
                    [scanner scanUpToString:@"-->" intoString:NULL];
                    [scanner scanString:@"-->" intoString:NULL];
                    
                } else if ([scanner scanString:@"script" intoString:NULL]) {
                    
                    // Script tag where things don't need escaping!
                    [scanner scanUpToString:@"</script>" intoString:NULL];
                    [scanner scanString:@"</script>" intoString:NULL];
                    
                } else {
                    
                    // Tag - remove and replace with space unless it's
                    // a closing inline tag then dont replace with a space
                    if ([scanner scanString:@"/" intoString:NULL]) {
                        
                        // Closing tag - replace with space unless it's inline
                        tagName = nil; dontReplaceTagWithSpace = NO;
                        if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
                            tagName = [tagName lowercaseString];
                            dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
                                                       [tagName isEqualToString:@"b"] ||
                                                       [tagName isEqualToString:@"i"] ||
                                                       [tagName isEqualToString:@"q"] ||
                                                       [tagName isEqualToString:@"span"] ||
                                                       [tagName isEqualToString:@"em"] ||
                                                       [tagName isEqualToString:@"strong"] ||
                                                       [tagName isEqualToString:@"cite"] ||
                                                       [tagName isEqualToString:@"abbr"] ||
                                                       [tagName isEqualToString:@"acronym"] ||
                                                       [tagName isEqualToString:@"label"]);
                        }
                        
                        // Replace tag with string unless it was an inline
                        if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                        
                    }
                    
                    // Scan past tag
                    [scanner scanUpToString:@">" intoString:NULL];
                    [scanner scanString:@">" intoString:NULL];
                    
                }
                
            } else {
                
                // Stopped at whitespace - replace all whitespace and newlines with a space
                if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                    if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
                }
                
            }
            
        } while (![scanner isAtEnd]);
        
        // Cleanup
        
        // Decode HTML entities and return
        NSString *retString = [result pfStringByDecodingHTMLEntities];
        
        // Return
        return retString;
        
    }
}

- (NSString *) pfStringByDecodingHTMLEntities {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]];
}

- (NSString *) pfStringByEncodingHTMLEntities {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[self gtm_stringByEscapingForAsciiHTML]];
}

- (NSString *) pfStringByEncodingHTMLEntities:(BOOL)isUnicode {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:(isUnicode ? [self gtm_stringByEscapingForHTML] : [self gtm_stringByEscapingForAsciiHTML])];
}

- (NSString *) pfStringWithNewLinesAsBRs {
	@autoreleasepool {
        
        // Strange New lines:
        //	Next Line, U+0085
        //	Form Feed, U+000C
        //	Line Separator, U+2028
        //	Paragraph Separator, U+2029
        
        // Scanner
        NSScanner *scanner = [[NSScanner alloc] initWithString:self];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet *newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                             [NSString stringWithFormat:@"\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        // Scan
        do {
            
            // Get non new line characters
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            temp = nil;
            
            // Add <br /> s
            if ([scanner scanString:@"\r\n" intoString:nil]) {
                
                // Combine \r\n into just 1 <br />
                [result appendString:@"<br />"];
                
            } else if ([scanner scanCharactersFromSet:newLineCharacters intoString:&temp]) {
                
                // Scan other new line characters and add <br /> s
                if (temp) {
                    for (NSUInteger i = 0; i < temp.length; i++) {
                        [result appendString:@"<br />"];
                    }
                }
                
            }
            
        } while (![scanner isAtEnd]);
        
        // Cleanup & return
        NSString *retString = [NSString stringWithString:result];
        
        // Return
        return retString;
        
	}
}

- (NSString *) pfStringByRemovingNewLinesAndWhitespace {
	@autoreleasepool {
        
        // Strange New lines:
        //	Next Line, U+0085
        //	Form Feed, U+000C
        //	Line Separator, U+2028
        //	Paragraph Separator, U+2029
        
        // Scanner
        NSScanner *scanner = [[NSScanner alloc] initWithString:self];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                                          [NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unichar)0x0085, (unichar)0x000C, (unichar)0x2028, (unichar)0x2029]];
        // Scan
        while (![scanner isAtEnd]) {
            
            // Get non new line or whitespace characters
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            
            // Replace with a space
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                    [result appendString:@"\r\n"];
            }
            
        }
        
        // Cleanup
        
        // Return
        NSString *retString = [NSString stringWithString:result];
        
        // Return
        return retString;
	}
}

- (NSString *) pfStringByLinkifyingURLs {
    if (!NSClassFromString(@"NSRegularExpression")) return self;
    @autoreleasepool {
        NSString *pattern = @"(?<!=\")\\b((http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%%&amp;:/~\\+#]*[\\w\\-\\@?^=%%&amp;/~\\+#])?)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
                                                              withTemplate:@"<a href=\"$1\" class=\"linkified\">$1</a>"];
        return modifiedString;
    }
}

- (NSString *) pfStringByStrippingTags {
	@autoreleasepool {
        
        // Find first & and short-cut if we can
        NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
        if (ampIndex == NSNotFound) {
            return [NSString stringWithString:self]; // return copy of string as no tags found
        }
        
        // Scan and find all tags
        NSScanner *scanner = [NSScanner scannerWithString:self];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableSet *tags = [[NSMutableSet alloc] init];
        NSString *tag;
        do {
            
            // Scan up to <
            tag = nil;
            [scanner scanUpToString:@"<" intoString:NULL];
            [scanner scanUpToString:@">" intoString:&tag];
            
            // Add to set
            if (tag) {
                NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
                [tags addObject:t];
            }
            
        } while (![scanner isAtEnd]);
        
        // Strings
        NSMutableString *result = [[NSMutableString alloc] initWithString:self];
        NSString *finalString;
        
        // Replace tags
        NSString *replacement;
        for (NSString *t in tags) {
            
            // Replace tag with space unless it's an inline element
            replacement = @" ";
            if ([t isEqualToString:@"<a>"] ||
                [t isEqualToString:@"</a>"] ||
                [t isEqualToString:@"<span>"] ||
                [t isEqualToString:@"</span>"] ||
                [t isEqualToString:@"<strong>"] ||
                [t isEqualToString:@"</strong>"] ||
                [t isEqualToString:@"<em>"] ||
                [t isEqualToString:@"</em>"]) {
                replacement = @"";
            }
            
            // Replace
            [result replaceOccurrencesOfString:t
                                    withString:replacement
                                       options:NSLiteralSearch
                                         range:NSMakeRange(0, result.length)];
        }
        
        // Remove multi-spaces and line breaks
        finalString = [result pfStringByRemovingNewLinesAndWhitespace];
        
        // Cleanup
        
        // Return
        return finalString;
        
	}
}

@end
