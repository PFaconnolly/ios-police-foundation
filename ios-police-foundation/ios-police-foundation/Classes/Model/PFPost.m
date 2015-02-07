//
//  PFPost.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/12/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPost.h"

@implementation PFPost

- (id)initWithPostId:(NSUInteger)postId title:(NSString *)title date:(NSDate *)date content:(NSString *)content excerpt:(NSString *)excerpt link:(NSString *)link attachments:(NSDictionary *)attachments {
    self = [super init];
    if ( self ) {
        self.postId = postId;
        self.title = title;
        self.date = date;
        self.content = content;
        self.excerpt = excerpt;
        self.link = link;
        self.attachments = attachments;
    }
    return self;
}

@end
