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
#import "PFHTTPRequestOperationManager.h"
#import "PFBarberPoleView.h"
#import "PFAnalyticsManager.h"
#import "PFCommonTableViewCell.h"

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
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    TableViewCellConfigureBlock configureCellBlock = ^(PFCommonTableViewCell * cell, NSDictionary * tag) {
        cell.titleLabel.text = [tag objectForKey:WP_TAG_NAME_KEY];
        cell.descriptionLabel.text = [tag objectForKey:WP_TAG_DESCRIPTION_KEY];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    TableViewCellSelectBlock selectCellBlock = ^(NSIndexPath * indexPath , NSDictionary * tag) {
        NSString * selectedTagSlug = [tag objectForKey:WP_TAG_SLUG_KEY];
        
        // track selected category & tag
        NSString * selectedCategorySlug = ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedCategorySlug;
        NSString * categoryAndSlugTrackingLabel = [NSString stringWithFormat:@"%@ / %@", selectedCategorySlug, selectedTagSlug];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_CATEGORY_AND_TAG_ACTION label:categoryAndSlugTrackingLabel value:nil];
        
        // save selected tag slug
        ((PFAppDelegate *)[[UIApplication sharedApplication] delegate]).selectedTagSlug = selectedTagSlug;
        
        // segue to posts
        [self performSegueWithIdentifier:@"tagsToPostsSegue" sender:self];
    };
    
    self.tags = [NSArray array];
    self.tagsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.tags
                                                         cellIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]
                                                     configureCellBlock:configureCellBlock
                                                        selectCellBlock:selectCellBlock];
    
    self.tableView.dataSource = self.tagsArrayDataSource;
    self.tableView.delegate = self.tagsArrayDataSource;
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

//#pragma mark - UITableViewDelegate methods
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    // Dynamic height table cells in iOS 8 need only an estimated row height
//    // and the UITableViewAutomaticDimension specified. iOS 7 and below need a
//    // prototype cell
//    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//    {
//        return UITableViewAutomaticDimension;
//    }
//    
//    PFCommonTableViewCell * prototypeCell = (PFTagTableViewCell *)[PFTagTableViewCell prototypeCell];
//
//    NSDictionary * tag = [self.tagsArrayDataSource itemAtIndexPath:indexPath];
//    [prototypeCell setTagData:tag];
//    
//    CGFloat height = [prototypeCell pfGetCellHeightForTableView:tableView];
//    DDLogVerbose(@"row: %li height: %f", (long)indexPath.row, height);
//    DDLogVerbose(@"-");
//    DDLogVerbose(@"-");
//    return height;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    }

@end
