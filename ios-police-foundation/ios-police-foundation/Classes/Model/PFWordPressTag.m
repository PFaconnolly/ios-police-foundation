//
//  PFWordPressTag.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFWordPressTag.h"

@implementation PFWordPressTag

- (id)initWithName:(NSString *)name summary:(NSString *)summary slug:(NSString *)slug {
    self = [super init];
    if ( self ) {
        self.name = name;
        self.summary = summary;
        self.slug = slug;
    }
    return self;
}

@end
