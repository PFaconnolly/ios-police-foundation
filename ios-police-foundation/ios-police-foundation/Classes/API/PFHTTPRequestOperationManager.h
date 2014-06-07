//
//  PFRequestOperationManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface PFHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (id)sharedManager;

- (void)getCategoriesWithParameters:(NSDictionary *)parameters
                            successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                            failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getTagsWithParameters:(NSDictionary *)parameters
                 successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                 failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getPostsWithParameters:(NSDictionary *)parameters
                  successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                  failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

- (void)getPostWithId:(NSString*)postId
           parameters:(NSDictionary *)parameters
         successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
         failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

@end
