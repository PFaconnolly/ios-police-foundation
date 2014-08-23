//
//  PFTagsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFTagsViewController.h"
#import "PFAppDelegate.h"
#import "PFArrayDataSource.h"
#import "PFTagTableViewCell.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFBarberPoleView.h"

@interface PFTagsViewController ()

@property (strong, nonatomic) NSArray * tags;
@property (strong, nonatomic) PFArrayDataSource *tagsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PFTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tags";

    [self setupTableView];
    [self fetchCategories];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Private methods

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFTagTableViewCell * cell, NSDictionary * category) {
        cell.tagLabel.text = [category objectForKey:@"name"];
        cell.descriptionLabel.text = [category objectForKey:@"description"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.tags = [NSArray array];
    self.tagsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.tags
                                                         cellIdentifier:@"Cell"
                                                     configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.tagsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFTagTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

- (void)fetchCategories {
    
    [self showBarberPole];
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getTagsWithParameters:nil
                                                            successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                @strongify(self)
                                                                NSDictionary * response = (NSDictionary *)responseObject;
                                                                self->_tags = [response objectForKey:@"tags"];
                                                                [self->_tagsArrayDataSource reloadItems:self->_tags];
                                                                [self->_tableView reloadData];
                                                                
                                                                [self hideBarberPole];
                                                            }
                                                            failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                [UIAlertView showWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                [self hideBarberPole];
                                                            }];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // set the selected tag on app delegate
    NSDictionary * tag = [self.tagsArrayDataSource itemAtIndexPath:indexPath];
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedTagSlug = [tag objectForKey:@"slug"];
    
    // segue to posts view controller
    [self performSegueWithIdentifier:@"tagsToPostsSegue" sender:self];
}

@end
