//
//  PFRSSHTTPRequestOperationManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 7/26/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface PFRSSHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (id)sharedManager;

- (void)getRssPostsWithParameters:(NSDictionary *)parameters
                     successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                     failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock;

@end
