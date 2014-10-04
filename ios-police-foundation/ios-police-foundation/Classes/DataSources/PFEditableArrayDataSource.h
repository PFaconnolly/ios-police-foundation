//
//  PFEditableArrayDataSource.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/21/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFArrayDataSource.h"

typedef void (^ItemDeletedBlock)(NSUInteger count);

@interface PFEditableArrayDataSource : PFArrayDataSource

@property (nonatomic, copy) ItemDeletedBlock itemDeletedBlock;

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    selectCellBlock:(TableViewCellSelectBlock)aSelectCellBlock
   itemDeletedBlock:(ItemDeletedBlock)anItemDeletedBlock;


@end
