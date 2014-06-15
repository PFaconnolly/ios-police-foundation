//
//  PFNewsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFNewsViewController.h"

@interface PFNewsViewController () <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PFNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // set the selected category
    /*NSDictionary * category = [self.categoriesArrayDataSource itemAtIndexPath:indexPath];
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug = [category objectForKey:@"slug"];
    
    PFTagsViewController * tagsViewController = [[PFTagsViewController alloc] initWithNibName:@"PFTagsViewController" bundle:nil];
    [self.navigationController pushViewController:tagsViewController animated:YES];*/
}


@end
