//
//  PFCategoriesViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/18/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFCategoriesViewController.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFCategoryTableViewCell.h"
#import "PFArrayDataSource.h"

@interface PFCategoriesViewController ()

@property (nonatomic, strong) PFArrayDataSource *categoriesArrayDataSource;

@end

@implementation PFCategoriesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Categories";
    
    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView
{
    TableViewCellConfigureBlock configureCellBlock = ^(PFCategoryTableViewCell * cell, NSDictionary * category) {
        cell.textLabel.text = [category objectForKey:@"name"];
        cell.detailTextLabel.text = [category objectForKey:@"description"];
    };
    
    __block NSArray * categories = nil;
    
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getCategoriesWithParameters:nil
                                                                  successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
                                                                      NSDictionary * __unused response = (NSDictionary *)responseObject;
                                                                      categories = [response objectForKey:@"categories"];
                                                                      self.categoriesArrayDataSource = [[PFArrayDataSource alloc] initWithItems:categories
                                                                                                                                 cellIdentifier:@"Cell"
                                                                                                                             configureCellBlock:configureCellBlock];
                                                                      
                                                                      self.tableView.dataSource = self.categoriesArrayDataSource;
                                                                      [self.tableView reloadData];
                                                                  }
                                                                  failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                      
                                                                  }];
    
    [self.tableView registerNib:[PFCategoryTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

@end

