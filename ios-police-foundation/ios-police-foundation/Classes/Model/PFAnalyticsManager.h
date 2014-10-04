//
//  PFAnalyticsManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

// Google Analytics categories
static NSString * GA_SYSTEM_ACTION_CATEGORY = @"System Action";
static NSString * GA_USER_ACTION_CATEGORY = @"User Action";

// Google Analytics actions
static NSString * GA_APPLICATION_LAUNCHED_ACTION = @"Application launched";
static NSString * GA_SELECTED_CATEGORY_ACTION = @"User selected category";
static NSString * GA_SELECTED_TAG_ACTION = @"User selected tag";
static NSString * GA_SELECTED_CATEGORY_AND_TAG_ACTION = @"User selected category and tag";
static NSString * GA_SELECTED_POST_ACTION = @"User selected WordPress post";
static NSString * GA_SELECTED_RSS_POST_ACTION = @"User selected RSS post";

@interface PFAnalyticsManager : NSObject

+ (id)sharedManager;

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end
