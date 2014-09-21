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
#import "PFCommonTableViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFCategoriesViewController ()

@property (strong, nonatomic) NSArray * categories;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFArrayDataSource * categoriesDataSource;

@end

@implementation PFCategoriesViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Research";
    [self setUpTableView];
    [self fetchCategories];
    
    UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshButtonTapped:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonTapped:)];
    self.navigationItem.leftBarButtonItem = searchButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.screenName = @"WordPress Research Screen";
}


#pragma mark - IBActions

- (void)refreshButtonTapped:(id)sender {
    [self fetchCategories];
}

- (void)searchButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"presentSearchSegue" sender:self];
}


#pragma mark - Private methods

- (void)setUpTableView {
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Configuration cell block
    TableViewCellConfigureBlock configureCellBlock = ^(PFCommonTableViewCell * cell, NSDictionary * item) {
        cell.titleLabel.text =  [item valueForKey:WP_CATEGORY_NAME_KEY];
        cell.descriptionLabel.text = [item valueForKey:WP_CATEGORY_DESCRIPTION_KEY];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    // Selection cell block
    TableViewCellSelectBlock selectCellBlock = ^(NSIndexPath * path, NSDictionary * item) {
        // track selected category
        NSString * selectedCategorySlug = [item objectForKey:WP_CATEGORY_SLUG_KEY];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_ACTION label:selectedCategorySlug value:nil];
        
        // save selected category
        ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug = selectedCategorySlug;
        
        [self performSegueWithIdentifier:@"categoriesToTagsSegue" sender:self];
    };

    self.categoriesDataSource = [[PFArrayDataSource alloc] initWithItems:self.categories
                                                          cellIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]
                                                      configureCellBlock:configureCellBlock
                                                         selectCellBlock:selectCellBlock];
    
    self.tableView.dataSource = self.categoriesDataSource;
    self.tableView.delegate = self.categoriesDataSource;
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
                                                                      [self->_categoriesDataSource reloadItems:self->_categories];
                                                                      [self->_tableView reloadData];
                                                                      [self hideBarberPole];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                      [self hideBarberPole];
                                                                  }];
}

@end

