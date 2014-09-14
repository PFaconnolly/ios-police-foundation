//
//  PFTableViewCell.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTableViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation PFTableViewCell

+ (UITableViewCell *)prototypeCell {
    static dispatch_once_t once;
    static NSMutableDictionary * prototypeCells;
    dispatch_once(&once, ^ {
        prototypeCells = [[NSMutableDictionary alloc] init];
    });
    
    NSString * key = NSStringFromClass(self);
    @synchronized ( prototypeCells ) {
        UITableViewCell * retval = prototypeCells[key];
        if ( ! retval ) {
            retval = [self loadCellFromNibWithReuseIdentifier:key];
            prototypeCells[key] = retval;
        }
        return retval;
    }
}

#pragma mark - Private Class methods

+ (UITableViewCell *)loadCellFromNibWithReuseIdentifier:(NSString *)reuseIdentifier {
    //	load cell from nib file
    UITableViewCell * retval = [[NSBundle mainBundle] pfFindObjectInNibNamed:NSStringFromClass(self.class) owner:nil byClass:(self.class)];
    DDLogVerbose(@"Cell loaded from nib: %@.", retval);
    
    //	verify reuse identifier was set properly in nib
    if ( ! [retval.reuseIdentifier isEqualToString:reuseIdentifier] ) {
        DDLogWarn(@"Cell reuse identifier \"%@\" is not set to expected value \"%@\". "
                  "The cell will not be properly reused. "
                  "Fix this by setting the reuse identifier with Interface Builder.",
                  retval.reuseIdentifier, reuseIdentifier);
    }
    
    return retval;
}

@end
