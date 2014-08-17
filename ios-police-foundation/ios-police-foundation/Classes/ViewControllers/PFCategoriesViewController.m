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
#import "PFBarberPoleView.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFCategoriesViewController ()

@property (strong, nonatomic) NSArray * categories;
@property (strong, nonatomic) PFArrayDataSource *categoriesArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PFCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Research";
    [self setupTableView];
    [self fetchCategories];
    
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)refreshButtonTapped:(id)sender {
    [self fetchCategories];
}

#pragma mark - Private methods

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFCategoryTableViewCell * cell, NSDictionary * category) {
        [cell setCategory:category];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.categories = [NSArray array];
    self.categoriesArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.categories
                                                               cellIdentifier:@"Cell"
                                                           configureCellBlock:configureCellBlock];
    self.tableView.rowHeight = 70;
    self.tableView.dataSource = self.categoriesArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFCategoryTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

- (void)fetchCategories {
    
    [self showBarberPole];
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getCategoriesWithParameters:nil
                                                                  successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      @strongify(self)
                                                                      NSDictionary * response = (NSDictionary *)responseObject;
                                                                      self->_categories = [response objectForKey:@"categories"];
                                                                      [self->_categoriesArrayDataSource reloadItems:self->_categories];
                                                                      [self->_tableView reloadData];
                                                                      
                                                                      [self hideBarberPole];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                                      [exception raise];

                                                                      [self hideBarberPole];
                                                                  }];
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // set the selected category on app delegate
    NSDictionary * category = [self.categoriesArrayDataSource itemAtIndexPath:indexPath];
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug = [category objectForKey:@"slug"];
    
    [self performSegueWithIdentifier:@"categoriesToTagsSegue" sender:self];
}

@end

