//
//  PFArrayDataSource.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFArrayDataSource.h"
#import "PFFileDownloadManager.h"
#import "PFCommonTableViewCell.h"

@interface PFArrayDataSource ()

@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, copy) NSString * cellIdentifier;
@property (strong, nonatomic) NSMutableDictionary * offscreenCells;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) TableViewCellSelectBlock selectCellBlock;

@end

@implementation PFArrayDataSource

- (id)init {
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
    selectCellBlock:(TableViewCellSelectBlock)aSelectCellBlock {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray arrayWithArray:anItems];
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
        self.selectCellBlock = [aSelectCellBlock copy];
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
    PFCommonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    
    [cell updateFonts];
    
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
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
                [UIAlertView pfShowWithTitle:@"File was not deleted" message:error.localizedDescription];
                return;
            }
            
            // remove file from items and reload table
            [self.items removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }];
    }
}

#pragma mark UITableViewDelegate methods 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This project has only one cell identifier, but if you are have more than one, this is the time
    // to figure out which reuse identifier should be used for the cell at this index path.
    NSString * reuseIdentifier = [PFCommonTableViewCell pfCellReuseIdentifier];
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    PFCommonTableViewCell * cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[PFCommonTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    // Configure the cell for this indexPath
    [cell updateFonts];
    NSDictionary * item = [self itemAtIndexPath:indexPath];
    
    if ( self.configureCellBlock ) {
        self.configureCellBlock(cell, item);
    }
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.selectCellBlock ) {
        NSDictionary * item = [self itemAtIndexPath:indexPath];
        self.selectCellBlock(indexPath, item);
    }
}

@end
