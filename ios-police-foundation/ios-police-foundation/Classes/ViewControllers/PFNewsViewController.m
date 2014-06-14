//
//  PFNewsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFNewsViewController.h"

@interface PFNewsViewController () <UITableViewDelegate>

@end

@implementation PFNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
