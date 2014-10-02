//
//  PFResearchViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 10/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFResearchViewController.h"
#import "PFCommonTableViewCell.h"
#import "PFAnalyticsManager.h"
#import "PFHTTPRequestOperationManager.h"
#import "PFPostDetailsViewController.h"

typedef void (^TableViewCellConfigureBlock)(id cell, id indexPath);
typedef void (^TableViewCellSelectBlock)(id indexPath);

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFResearchViewController ()

@property (strong, nonatomic) NSArray * posts;
@property (strong, nonatomic) IBOutlet UITableView * tableView;
@property (strong, nonatomic) NSMutableDictionary * offscreenCells;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) TableViewCellSelectBlock selectCellBlock;

@end

@implementation PFResearchViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Posts";
    [self setupTableView];
    [self fetchPosts];
    
    UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonTapped:)];
    self.navigationItem.leftBarButtonItem = searchButton;
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchPosts];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.screenName = @"WordPress Research Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"researchToPostDetailsSegue"] ) {
        NSDictionary * post = [self.posts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        NSString * postId = [NSString stringWithFormat:@"%@", [post objectForKey:WP_POST_ID_KEY]];
        ((PFPostDetailsViewController *)segue.destinationViewController).wordPressPostId = postId;
    }
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * title = @"";
    switch(section) {
        case 0: title = @"Most Recent"; break;
        case 1: title = @"Search"; break;
        default: break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch(section) {
        case 0: rows = self.posts.count; break;
        case 1: rows = 2; break;
        default: rows = 0; break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFCommonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    
    [cell updateFonts];
    
    // configure cell
    if ( self.configureCellBlock ) {
        self.configureCellBlock(cell, indexPath);
    }

    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This project has only one cell identifier, but if you are have more than one, this is the time
    // to figure out which reuse identifier should be used for the cell at this index path.
    NSString * reuseIdentifier = [PFCommonTableViewCell pfCellReuseIdentifier];
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    PFCommonTableViewCell * cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[PFCommonTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    // Configure the cell for this indexPath
    [cell updateFonts];
    
    if ( self.configureCellBlock ) {
        self.configureCellBlock(cell, indexPath);
    }
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.selectCellBlock ) {
        self.selectCellBlock(indexPath);
    }
}


#pragma mark - Private methods

- (void)setupTableView {
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    @weakify(self);
    self.configureCellBlock = ^(PFCommonTableViewCell * cell, NSIndexPath * indexPath) {
        @strongify(self);
        switch ( indexPath.section ) {
            case 0: {
                // configure cell
                NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
                cell.titleLabel.text = [[post objectForKey:WP_POST_TITLE_KEY] pfStringByConvertingHTMLToPlainText];
                NSDate * date = [NSDate pfDateFromIso8601String:[post objectForKey:WP_POST_DATE_KEY]];
                NSString * excerpt = [[post objectForKey:WP_POST_EXCERPT_KEY] pfStringByConvertingHTMLToPlainText];                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"%@\r\n\r\n%@", [NSString pfMediumDateStringFromDate:date], excerpt];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 1: {
                switch ( indexPath.row ) {
                    case 0: {
                        cell.titleLabel.text = @"Categories";
                        cell.descriptionLabel.text = nil;
                        break;
                    }
                    case 1: {
                        cell.titleLabel.text = @"Tags";
                        cell.descriptionLabel.text = nil;
                        break;
                    }
                    default: break;
                }
                break;
            }
            default:
                break;
        }
    };
    
    self.selectCellBlock = ^(NSIndexPath * indexPath) {
        @strongify(self);
        
        switch ( indexPath.section ) {
            case 0: {
                // track selected post and seque to post details
                NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
                NSString * postURL = [post objectForKey:WP_POST_URL_KEY];
                [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_POST_ACTION label:postURL value:nil];
                [self performSegueWithIdentifier:@"researchToPostDetailsSegue" sender:self];
                break;
            }
            case 1: {
                switch ( indexPath.row ) {
                    case 0: [self performSegueWithIdentifier:@"researchToCategoriesSegue" sender:self]; break;
                    case 1: [self performSegueWithIdentifier:@"researchToTagsSegue" sender:self]; break;
                    default: break;
                }
                break;
            }
            default: break;
        }
    };
    
    self.posts = [NSArray array];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // hide extra rows
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)fetchPosts {
    [self showBarberPole];
    
    @weakify(self)
    
    NSString * fields = [@[WP_POST_ID_KEY, WP_POST_TITLE_KEY, WP_POST_EXCERPT_KEY, WP_POST_DATE_KEY, WP_POST_URL_KEY] componentsJoinedByString:@","];    // ID, title, date, URL
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:@[fields, @(20), @"DESC"]
                                                            forKeys:@[WP_SEARCH_POSTS_API_FIELDS_KEY, WP_SEARCH_POSTS_API_NUMBER_OF_RESULTS_KEY, WP_SEARCH_POSTS_API_ORDER_KEY]];
    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostsWithParameters:parameters
                                                             successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 @strongify(self)
                                                                 if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                                     NSDictionary * response = (NSDictionary *)responseObject;
                                                                     self->_posts = [response objectForKey:WP_POSTS_API_RESPONSE_POSTS_KEY];
                                                                     [self->_tableView reloadData];
                                                                 }
                                                                 
                                                                 [self hideBarberPole];
                                                             }
                                                             failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                 [self hideBarberPole];
                                                             }];
}

- (void)searchButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"presentSearchSegue" sender:self];
}

@end
