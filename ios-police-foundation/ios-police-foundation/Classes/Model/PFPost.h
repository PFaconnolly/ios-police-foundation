//
//  PFPost.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFPost : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * excerpt;

@end
