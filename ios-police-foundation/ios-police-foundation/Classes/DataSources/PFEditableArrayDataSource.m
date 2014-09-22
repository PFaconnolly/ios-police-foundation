//
//  PFEditableArrayDataSource.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/21/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFEditableArrayDataSource.h"
#import "PFFileDownloadManager.h"

@interface PFArrayDataSource ()

@property (nonatomic, strong) NSMutableArray * items;

@end

@implementation PFEditableArrayDataSource

#pragma mark - UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        NSDictionary * document = [self itemAtIndexPath:indexPath];
        NSString * filePath = [document objectForKey:PFFilePath];
        
        // Delete item at filePath
        [[PFFileDownloadManager sharedManager] deleteFileAtPath:filePath withCompletion:^(NSError * error) {
            if ( error ) {
                [UIAlertView pfShowWithTitle:@"File was not deleted" message:error.localizedDescription];
                return;
            }
            
            // remove file from items and reload table
            [self.items removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }];
    }
}

#pragma mark - UITableViewDelegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

@end
