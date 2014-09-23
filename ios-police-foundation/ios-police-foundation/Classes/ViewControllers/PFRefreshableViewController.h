//
//  PFRefreshableViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/22/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFViewController.h"

@interface PFRefreshableViewController : PFViewController

@property (nonatomic, copy) void (^refreshBlock)();

@end
