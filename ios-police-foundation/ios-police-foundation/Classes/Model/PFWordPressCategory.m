//
//  PFWordPressCategory.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/11/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWordPressCategory.h"

@implementation PFWordPressCategory

- (id)init {
    self = [super init];
    if ( self ) {
        
    }
    return self;
}
- (id)initWithCategoryId:(NSUInteger)categoryId summary:(NSString *)summary name:(NSString *)name parentId:(NSUInteger)parentId postCount:(NSUInteger)postCount slug:(NSString *)slug {
    self = [super init];
    if ( self ) {
        self.categoryId = categoryId;
        self.summary = summary;
        self.name = name;
        self.parentId = parentId;
        self.postCount = postCount;
        self.slug = slug;
        self.subCategories = [NSMutableArray array];
    }
    return self;
}

@end
