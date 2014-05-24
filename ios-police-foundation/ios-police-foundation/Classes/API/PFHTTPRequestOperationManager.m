//
//  PFHTTPRequestOperationManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFHTTPRequestOperationManager.h"
#import "NSString+PFExtensions.h"

static NSString * BASE_URL = @"https://public-api.wordpress.com/rest/v1/";
static NSString * HOST_API_ID = @"pfaconnolly.wordpress.com";

@implementation PFHTTPRequestOperationManager

+ (id)sharedManager {
    static PFHTTPRequestOperationManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [NSURL URLWithString:BASE_URL];
        instance = [[self alloc] initWithBaseURL:url];
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

- (void)getCategoriesWithParameters:(NSDictionary *)parameters
                       successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                       failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = [BASE_URL stringByAppendingString:@"sites/<id>/categories/"];
    url = [url stringByReplacingOccurrencesOfString:@"<id>" withString:HOST_API_ID];
    url = [url pfStringByAppendingQueryStringParameters:parameters];
    [self getRequestWithUrl:url parameters:nil successBlock:successBlock failureBlock:failureBlock];
}

- (void)getPostsWithParameters:(NSDictionary *)parameters
                  successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                  failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = [BASE_URL stringByAppendingString:@"sites/<id>/posts/"];
    url = [url stringByReplacingOccurrencesOfString:@"<id>" withString:HOST_API_ID];
    url = [url pfStringByAppendingQueryStringParameters:parameters];
    [self getRequestWithUrl:url parameters:nil successBlock:successBlock failureBlock:failureBlock];
}

- (void)getPostWithId:(NSString*)postId
           parameters:(NSDictionary *)parameters
              successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
              failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = [BASE_URL stringByAppendingString:@"sites/<id>/posts/<post_id>"];
    url = [url stringByReplacingOccurrencesOfString:@"<id>" withString:HOST_API_ID];
    url = [url stringByReplacingOccurrencesOfString:@"<post_id>" withString:postId];
    url = [url pfStringByAppendingQueryStringParameters:parameters];
    [self getRequestWithUrl:url parameters:nil successBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - Custom methods 

- (void)getRequestWithUrl:(NSString *)url
               parameters:(id)parameters
             successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
             failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    [self GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(operation, error);
    }];
}

@end
