//
//  PFPostsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostsViewController.h"
#import "PFAppDelegate.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFArrayDataSource.h"
#import "PFPostTableViewCell.h"
#import "PFPostDetailsViewController.h"

@interface PFPostsViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) PFArrayDataSource * postsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation PFPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.title = @"Posts";
    [self setupTableView];
    [self fetchPosts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFPostTableViewCell * cell, NSDictionary * category) {
        cell.textLabel.text = [category objectForKey:@"title"];
        cell.detailTextLabel.text = [category objectForKey:@"date"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.posts = [NSArray array];
    self.postsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.posts
                                                          cellIdentifier:@"Cell"
                                                      configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.postsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFPostTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

- (void)fetchPosts {
    
    @weakify(self)
    
    NSString * category = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug;
    NSString * tag = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedTagSlug;
    NSArray * fields = [NSArray arrayWithObject:@"ID, title, date"];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[category, tag, fields] forKeys:@[@"category", @"tag", @"fields"]];
    
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostsWithParameters:parameters
                                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 @strongify(self)
                                                                 if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                                     NSDictionary * response = (NSDictionary *)responseObject;
                                                                     self->_posts = [response objectForKey:@"posts"];
                                                                     [self->_postsArrayDataSource reloadItems:self->_posts];
                                                                     [self->_tableView reloadData];
                                                                 }
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
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:indexPath];
    PFPostDetailsViewController * postDetailsViewController = [[PFPostDetailsViewController alloc] initWithNibName:@"PFPostDetailsViewController" bundle:nil];
    postDetailsViewController.postID = [NSString stringWithFormat:@"%@", [post objectForKey:@"ID"]];
    [self.navigationController pushViewController:postDetailsViewController animated:YES];
}

@end
