//
//  PFWordPressTag.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFWordPressTag : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * summary;
@property (nonatomic, copy) NSString * slug;

- (id)initWithName:(NSString *)name summary:(NSString *)summary slug:(NSString *)slug;

@end
