//
//  PFAnalyticsManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFAnalyticsManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

static NSString * GA_TRACKING_ID = @"UA-34908763-4";


@implementation PFAnalyticsManager

+ (id)sharedManager {
    static PFAnalyticsManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (PFAnalyticsManager *)init {
    self = [super init];
    if ( self ) {
        
        // Google Analytics
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = 20;
        
        // Optional: set Logger to VERBOSE for debug information.
        //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    }
    
    return self;
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    // Initialize tracker. Replace with your tracking ID.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING_ID];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category           // Event category (required)
                                                          action:action             // Event action (required)
                                                           label:label              // Event label
                                                           value:value] build]];    // Event value
}

@end
