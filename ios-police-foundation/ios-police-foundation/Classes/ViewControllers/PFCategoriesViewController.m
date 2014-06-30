//
//  PFCategoriesViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCategoriesViewController.h"
#import "PFAppDelegate.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFCategoryTableViewCell.h"
#import "PFArrayDataSource.h"
#import "PFTagsViewController.h"

@interface PFCategoriesViewController ()

@property (strong, nonatomic) NSArray * categories;
@property (strong, nonatomic) PFArrayDataSource *categoriesArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PFCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Categories";
    [self setupTableView];
    [self fetchCategories];
    
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)refreshButtonTapped:(id)sender {
    [self fetchCategories];
}


#pragma mark - Private methods

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFCategoryTableViewCell * cell, NSDictionary * category) {
        cell.textLabel.text = [category objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@) %@", [category objectForKey:@"post_count"], [category objectForKey:@"description"]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.categories = [NSArray array];
    self.categoriesArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.categories
                                                               cellIdentifier:@"Cell"
                                                           configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.categoriesArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFCategoryTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

- (void)fetchCategories {
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getCategoriesWithParameters:nil
                                                                  successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      @strongify(self)
                                                                      NSDictionary * response = (NSDictionary *)responseObject;
                                                                      self->_categories = [response objectForKey:@"categories"];
                                                                      [self->_categoriesArrayDataSource reloadItems:self->_categories];
                                                                      [self->_tableView reloadData];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                                      [exception raise];
                                                                  }];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // set the selected category on app delegate
    NSDictionary * category = [self.categoriesArrayDataSource itemAtIndexPath:indexPath];
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug = [category objectForKey:@"slug"];
    
    [self performSegueWithIdentifier:@"categoriesToTagsSegue" sender:self];
}

@end

