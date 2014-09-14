//
//  NSBundle+PFExtensions.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "NSBundle+PFExtensions.h"

@implementation NSBundle (PFExtensions)

- (id)pfFindObjectInNibNamed:(NSString *)nibName owner:(id)theOwner byClass:(Class)theClass {
    //	check if the nib file exists in the bundle; note: -pathForResource:ofType: will properly handle localizations
    //	and device specific nibs with ~iphone or ~ipad suffixes appropriately
    if ( ! [self pathForResource:nibName ofType:@"nib"] ) {
        return nil;
    }
    
    NSArray * items = [self loadNibNamed:nibName owner:theOwner options:nil];
    for ( id item in items ) {
        if ( [item isKindOfClass:[theClass class]] ) {
            return item;
        }
    }
    return nil;
}

@end
