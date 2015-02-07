//
//  PFWordPressCategory.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/11/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFWordPressCategory : NSObject

@property (nonatomic, assign) NSUInteger categoryId;
@property (nonatomic, copy) NSString * summary;             // can't use the word description
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) NSUInteger parentId;
@property (nonatomic, assign) NSUInteger postCount;
@property (nonatomic, copy) NSString * slug;
@property (nonatomic, strong) NSMutableArray * subCategories;

- (id)initWithCategoryId:(NSUInteger)categoryId summary:(NSString *)summary name:(NSString *)name parentId:(NSUInteger)parentId postCount:(NSUInteger)postCount slug:(NSString *)slug;

@end
