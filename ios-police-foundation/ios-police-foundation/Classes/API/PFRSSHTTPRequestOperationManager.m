//
//  PFRSSHTTPRequestOperationManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/26/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFRSSHTTPRequestOperationManager.h"

static NSString * BASE_URL = @"http://www.policefoundation.org/rss.xml";

static NSString * errorDomain = @"com.policefoundation.pfrsshttprequestoperationmanager";

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation PFRSSHTTPRequestOperationManager

+ (NSError *)error {
    return [NSError errorWithDomain:errorDomain code:0 userInfo:nil];
}

+ (id)sharedManager {
    static PFRSSHTTPRequestOperationManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [NSURL URLWithString:BASE_URL];
        instance = [[self alloc] initWithBaseURL:url];
        instance.responseSerializer = [AFXMLParserResponseSerializer new];
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    });
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if ( self != nil ){
        // initailization
    }
    return self;
}

- (void)getRssPostsWithParameters:(NSDictionary *)parameters
                     successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                     failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = BASE_URL;
    url = [url pfStringByAppendingQueryStringParameters:parameters];
    [self getRequestWithUrl:url parameters:nil successBlock:successBlock failureBlock:failureBlock];
}


#pragma mark - Custom methods

- (void)getRequestWithUrl:(NSString *)url
               parameters:(id)parameters
             successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
             failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    // Don't forget to URL encode
    [self GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSXMLParser * responseObject) {
        
        successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(operation, error);
    }];
}

@end
