//
//  PFMasterMenuViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/14/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFMasterMenuViewController.h"

@interface PFMasterMenuViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PFMasterMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Menu";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if ( ! cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch( indexPath.row ) {
        case 0:
            cell.textLabel.text = @"Categories";
            cell.imageView.image = [UIImage imageNamed:@"Star Icon"];
            break;
        case 1:
            cell.textLabel.text = @"News";
            break;
        case 2:
            cell.textLabel.text = @"About";
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ( indexPath.row ) {
        case 0: [self performSegueWithIdentifier:@"segueToCategories" sender:self]; break;
        case 1: [self performSegueWithIdentifier:@"segueToNews" sender:self]; break;
        case 2: [self performSegueWithIdentifier:@"segueToAbout" sender:self]; break;            
    }
}

@end
