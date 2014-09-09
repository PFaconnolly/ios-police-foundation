//
//  PFArrayDataSource.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFArrayDataSource.h"
#import "PFFileDownloadManager.h"

@interface PFArrayDataSource ()

@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, copy) NSString * cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;

@end

@implementation PFArrayDataSource

- (id)init {
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray arrayWithArray:anItems];
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[(NSUInteger) indexPath.row];
}

- (void)reloadItems:(NSArray *)items {
    self.items = [NSMutableArray arrayWithArray:items];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

// TO DO: Refactor this method into PFArrayDataSource subclass
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSDictionary * document = [self itemAtIndexPath:indexPath];
        NSString * filePath = [document objectForKey:PFFilePath];
        
        // Delete item at filePath
        [[PFFileDownloadManager sharedManager] deleteFileAtPath:filePath withCompletion:^(NSError * error) {
            if ( error ) {
                [UIAlertView showWithTitle:@"File was not deleted" message:error.localizedDescription];
                return;
            }
            
            // remove file from items and reload table
            [self.items removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }];
    }
}

@end
