//
//  PFRequestOperationManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "PFPost.h"

@interface PFHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (id)sharedManager;

- (void)getCategoriesWithParameters:(NSDictionary *)parameters
                            successBlock:(void (^)(AFHTTPRequestOperation * operation, NSArray * categories))successBlock
                            failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getTagsWithParameters:(NSDictionary *)parameters
                 successBlock:(void (^)(AFHTTPRequestOperation * operation, NSArray * tags))successBlock
                 failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getPostsWithParameters:(NSDictionary *)parameters
                  successBlock:(void (^)(AFHTTPRequestOperation * operation, NSArray * posts))successBlock
                  failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getPostWithId:(NSString*)postId
           parameters:(NSDictionary *)parameters
         successBlock:(void (^)(AFHTTPRequestOperation * operation, PFPost * post))successBlock
         failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

@end
