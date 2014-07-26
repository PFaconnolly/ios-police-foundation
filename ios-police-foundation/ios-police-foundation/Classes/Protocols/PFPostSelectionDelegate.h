//
//  PFPostSelectionDelegate.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/14/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFPostSelectionDelegate <NSObject>

@optional
- (void)selectPostWithId:(NSString *)postId;
- (void)selectPostWithRssPost:(NSDictionary *)rssPost;

@end
