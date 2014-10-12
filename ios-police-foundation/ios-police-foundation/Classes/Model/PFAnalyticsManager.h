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
static NSString * GA_SELECTED_POST_ACTION = @"User selected WordPress post";
static NSString * GA_SELECTED_RSS_POST_ACTION = @"User selected RSS post";
static NSString * GA_TEXT_SEARCH_ACTION = @"User text searched WordPress posts";
static NSString * GA_SHARED_ITEM_WITH_URL_ACTION = @"User shared item with URL";
static NSString * GA_VIEWED_FILE_NAME_ACTION = @"User viewed file with name";
static NSString * GA_VIEWED_WELCOME_INSTRUCTIONS_ACTION = @"User viewed welcome intro screen";
static NSString * GA_VIEWED_RESEARCH_INSTRUCTIONS_ACTION = @"User viewed research intro screen";
static NSString * GA_VIEWED_CATEGORIES_INSTRUCTIONS_ACTION = @"User viewed categories intro screen";
static NSString * GA_VIEWED_TAGS_INSTRUCTIONS_ACTION = @"User viewed tags intro screen";
static NSString * GA_VIEWED_NEWS_INSTRUCTIONS_ACTION = @"User viewed news intro screen";
static NSString * GA_VIEWED_DOCUMENTS_INSTRUCTIONS_ACTION = @"User viewed documents intro screen";

@interface PFAnalyticsManager : NSObject

+ (id)sharedManager;

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end
