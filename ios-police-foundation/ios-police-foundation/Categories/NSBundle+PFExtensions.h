//
//  NSBundle+PFExtensions.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/13/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (PFExtensions)

- (id)pfFindObjectInNibNamed:(NSString *)nibName owner:(id)theOwner byClass:(Class)theClass;

@end
