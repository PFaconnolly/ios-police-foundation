//
//  PFNewsViewController.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFViewController.h"
#import "PFPostSelectionDelegate.h"

@interface PFNewsViewController : PFViewController

@property (nonatomic, weak) id<PFPostSelectionDelegate> postSelectionDelegate;

@end
