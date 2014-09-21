//
//  PFArrayDataSource.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);
typedef void (^TableViewCellSelectBlock)(id indexPath, id item);

@interface PFArrayDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    selectCellBlock:(TableViewCellSelectBlock)aSelectCellBlock;

- (void)reloadItems:(NSArray *)items;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
