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
#import "PFAnalyticsManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

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
    
    self.screenName = @"WordPress Tags Screen";
}

#pragma mark - Private methods

- (void)setupTableView {
    TableViewCellConfigureBlock configureCellBlock = ^(PFTagTableViewCell * cell, NSDictionary * tag) {
        cell.tagLabel.text = [tag objectForKey:@"name"];
        cell.descriptionLabel.text = [tag objectForKey:@"description"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.tags = [NSArray array];
    self.tagsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.tags
                                                         cellIdentifier:[PFTagTableViewCell pfCellReuseIdentifier]
                                                     configureCellBlock:configureCellBlock];
    self.tableView.dataSource = self.tagsArrayDataSource;
    [self.tableView reloadData];
    
    [self.tableView registerNib:[PFTagTableViewCell pfNib] forCellReuseIdentifier:[PFTagTableViewCell pfCellReuseIdentifier]];
}

- (void)fetchCategories {
    
    [self showBarberPole];
    
    @weakify(self)
    // Fetch categories from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getTagsWithParameters:nil
                                                            successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                @strongify(self)
                                                                NSDictionary * response = (NSDictionary *)responseObject;
                                                                self->_tags = [response objectForKey:WP_TAGS_KEY];
                                                                [self->_tagsArrayDataSource reloadItems:self->_tags];
                                                                [self->_tableView reloadData];
                                                                
                                                                [self hideBarberPole];
                                                            }
                                                            failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                [self hideBarberPole];
                                                            }];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFTagTableViewCell * prototypeCell = (PFTagTableViewCell *)[PFTagTableViewCell prototypeCell];    
    NSDictionary * tag = [self.tagsArrayDataSource itemAtIndexPath:indexPath];
    prototypeCell.tagLabel.text = [tag objectForKey:@"name"];
    prototypeCell.descriptionLabel.text = [tag objectForKey:@"description"];
    prototypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CGFloat height = [prototypeCell pfGetCellHeightForTableView:tableView];
    DDLogVerbose(@"row: %li height: %f", (long)indexPath.row, height);
    DDLogVerbose(@"-");
    DDLogVerbose(@"-");
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * tag = [self.tagsArrayDataSource itemAtIndexPath:indexPath];
    NSString * selectedTagSlug = [tag objectForKey:WP_TAG_SLUG_KEY];
    
    // track selected category & tag
    NSString * selectedCategorySlug = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug;
    NSString * categoryAndSlugTrackingLabel = [NSString stringWithFormat:@"%@ / %@", selectedCategorySlug, selectedTagSlug];
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_AND_TAG_ACTION label:categoryAndSlugTrackingLabel value:nil];

    // save selected tag slug
    ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedTagSlug = selectedTagSlug;
    
    [self performSegueWithIdentifier:@"tagsToPostsSegue" sender:self];
}

@end
