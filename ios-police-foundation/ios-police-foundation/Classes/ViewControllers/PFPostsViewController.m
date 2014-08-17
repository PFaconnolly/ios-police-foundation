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
#import "NSDate+PFExtensions.h"
#import "NSString+PFExtensions.h"
#import "PFBarberPoleView.h"

@interface PFPostsViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) PFArrayDataSource * postsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation PFPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Posts";
    [self setupTableView];
    [self fetchPosts];
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        self.postSelectionDelegate = ((PFAppDelegate *)[UIApplication sharedApplication].delegate).detailsViewController;
    }
}

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFPostTableViewCell * cell, NSDictionary * category) {
        cell.titleLabel.text = [category objectForKey:@"title"];
        NSDate * date = [NSDate pfDateFromIso8601String:[category objectForKey:@"date"]];
        cell.dateLabel.text = [NSString pfMediumDateStringFromDate:date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.posts = [NSArray array];
    self.postsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.posts
                                                          cellIdentifier:@"Cell"
                                                      configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.postsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFPostTableViewCell nib] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = 70;
}

- (void)fetchPosts {

    [self showBarberPole];

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
    
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:indexPath];
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:@"ID"]];
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ) {
        
        [self performSegueWithIdentifier:@"postsToPostDetailsSegue" sender:self];
        
    } else if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        
        if ( [self.postSelectionDelegate respondsToSelector:@selector(selectPostWithId:) ] ) {
            [self.postSelectionDelegate selectPostWithId:postId];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary * post = [self.postsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:@"ID"]];
    ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
}

@end
