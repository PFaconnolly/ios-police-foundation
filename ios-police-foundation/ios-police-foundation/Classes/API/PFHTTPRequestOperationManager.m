//
//  PFHTTPRequestOperationManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/17/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFHTTPRequestOperationManager.h"
#import "PFWordPressCategory.h"

static NSString * BASE_URL = @"https://public-api.wordpress.com/rest/v1/";
static NSString * HOST_API_ID = @"pfaconnolly.wordpress.com";

static NSString * errorDomain = @"com.policefoundation.pfhttprequestoperationmanager";

@implementation PFHTTPRequestOperationManager

+ (NSError *)error {
    return [NSError errorWithDomain:errorDomain code:0 userInfo:nil];
}

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
                       successBlock:(void (^)(AFHTTPRequestOperation * operation, NSArray * categories))successBlock
                       failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = [BASE_URL stringByAppendingString:@"sites/<id>/categories/"];
    url = [url stringByReplacingOccurrencesOfString:@"<id>" withString:HOST_API_ID];
    url = [url pfStringByAppendingQueryStringParameters:parameters];
    [self getRequestWithUrl:url
                 parameters:nil
               successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                   // parse categories into model objects
                   NSArray * allCategories = [responseObject objectForKey:WP_CATEGORIES_KEY];
                   
                   if ( allCategories == nil || allCategories.count == 0 ) {
                       // no categories found. should this return an error instead?
                       successBlock(operation, nil);
                   }
                   
                   NSMutableArray * modelCategories = [NSMutableArray array];
                   
                   // convert JSON to model objects
                   [allCategories enumerateObjectsUsingBlock:^(NSDictionary * category, NSUInteger __unused idx, BOOL __unused *stop) {
                       NSNumber * categoryId = [category objectForKey:WP_CATEGORY_ID_KEY];
                       NSString * summary = [category objectForKey:WP_CATEGORY_DESCRIPTION_KEY];
                       NSString * name = [category objectForKey:WP_CATEGORY_NAME_KEY];
                       NSNumber * parentId = [category objectForKey:WP_CATEGORY_PARENT_ID_KEY];
                       NSNumber * postCount = [category objectForKey:WP_CATEGORY_POST_COUNT_KEY];
                       NSString * slug = [category objectForKey:WP_CATEGORY_SLUG_KEY];
                       
                       PFWordPressCategory * wordPressCategory = [[PFWordPressCategory alloc] initWithCategoryId:categoryId.unsignedIntegerValue
                                                                                                         summary:summary
                                                                                                            name:name
                                                                                                        parentId:parentId.unsignedIntegerValue
                                                                                                       postCount:postCount.unsignedIntegerValue
                                                                                                            slug:slug];
                       [modelCategories addObject:wordPressCategory];
                   }];
                   
                   NSMutableArray * organizedCategories = [NSMutableArray array];
                   
                   // organize categories into parents
                   [modelCategories enumerateObjectsUsingBlock:^(PFWordPressCategory * category, NSUInteger __unused idx, BOOL __unused *stop) {
                       if ( category.parentId == 0 ) {
                           [organizedCategories addObject:category];
                       }
                   }];
                   
                   // add children categories to parent categories
                   [modelCategories enumerateObjectsUsingBlock:^(PFWordPressCategory * category, NSUInteger __unused idx, BOOL __unused *stop) {
                       [organizedCategories enumerateObjectsUsingBlock:^(PFWordPressCategory * parentCategory, NSUInteger __unused idx, BOOL __unused *stop) {
                           if ( category.parentId == parentCategory.categoryId ) {
                               [parentCategory.subCategories addObject:category];
                           }
                       }];
                   }];
                   
                   successBlock(operation, organizedCategories);
               }
               failureBlock:failureBlock];
}

- (void)getTagsWithParameters:(NSDictionary *)parameters
                       successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                       failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    NSString * url = [BASE_URL stringByAppendingString:@"sites/<id>/tags/"];
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

- (void)getLastestPostWithParameters:(NSDictionary *)parameters
                        successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
                        failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {

    // fetch all posts, then fetch the post details for only the first post
    [self getPostsWithParameters:parameters successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
            NSDictionary * response = (NSDictionary *)responseObject;
            NSArray * posts = [response objectForKey:@"posts"];
            
            NSDictionary * firstPost = posts.firstObject;
            if ( firstPost == nil ) {
                failureBlock(operation, [PFHTTPRequestOperationManager error]);
            }
            
            NSString * postId = [NSString stringWithFormat:@"%@", [firstPost objectForKey:@"ID"]];
            if ( postId == nil ) {
                failureBlock(operation, [PFHTTPRequestOperationManager error]);
            }
            
            // fetch post details for the first post id found
            [self getPostWithId:postId parameters:nil successBlock:successBlock failureBlock:failureBlock];
        }
        
    } failureBlock:failureBlock];
}




#pragma mark - Custom methods

- (void)getRequestWithUrl:(NSString *)url
               parameters:(id)parameters
             successBlock:(void (^)(AFHTTPRequestOperation * operation, id responseObject))successBlock
             failureBlock:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failureBlock {
    // Don't forget to URL encode
    [self GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(operation, error);
    }];
}

@end
