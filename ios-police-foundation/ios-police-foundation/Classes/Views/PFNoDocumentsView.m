//
//  PFNoDocumentsView.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/5/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFNoDocumentsView.h"

@implementation PFNoDocumentsView

+ (NSString *)pfNibName {
    NSString * nibName = NSStringFromClass(self.class);
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        nibName = [NSString stringWithFormat:@"%@~iPad", nibName];
    }
    return nibName;
}

@end
