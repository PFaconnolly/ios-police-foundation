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
#import "PFAnalyticsManager.h"

// categories response keys
static NSString * WP_CATEGORIES_KEY = @"categories";

// category keys
static NSString * WP_CATEGORY_NAME_KEY = @"name";
static NSString * WP_CATEGORY_SLUG_KEY = @"slug";

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
    
    self.screenName = @"WordPress Research Screen";
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
                                                                      self->_categories = [response objectForKey:WP_CATEGORIES_KEY];
                                                                      [self->_categoriesArrayDataSource reloadItems:self->_categories];
                                                                      [self->_tableView reloadData];
                                                                      
                                                                      [self hideBarberPole];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      [UIAlertView showWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                      [self hideBarberPole];
                                                                  }];
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // set the selected category on app delegate
    NSDictionary * category = [self.categoriesArrayDataSource itemAtIndexPath:indexPath];
    
    // track selected category
    NSString * selectedCategorySlug = [category objectForKey:WP_CATEGORY_SLUG_KEY];
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_ACTION label:selectedCategorySlug value:nil];
    
    // save selected category
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug = selectedCategorySlug;
    
    [self performSegueWithIdentifier:@"categoriesToTagsSegue" sender:self];
}

@end

