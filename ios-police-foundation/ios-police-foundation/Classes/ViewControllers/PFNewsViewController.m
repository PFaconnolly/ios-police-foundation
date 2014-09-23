//
//  PFNewsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 6/2/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFNewsViewController.h"
#import "PFArrayDataSource.h"
#import "PFBarberPoleView.h"
#import "PFRSSHTTPRequestOperationManager.h"
#import "PFPostDetailsViewController.h"
#import "PFAppDelegate.h"
#import "PFCommonTableViewCell.h"

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

@interface PFNewsViewController () <UITableViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray * rssPosts;
@property (strong, nonatomic) NSMutableDictionary * rssPost;
@property (strong, nonatomic) PFArrayDataSource * rssPostsArrayDataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

// nasty xml parsing
@property (strong, nonatomic) NSString * currentElementName;
@property (strong, nonatomic) NSMutableString * currentFoundCharacters;

@end

@implementation PFNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
    
    [self fetchRssPosts];
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchRssPosts];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    self.screenName = @"RSS News Screen";
}

- (void)setupTableView {
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    TableViewCellConfigureBlock configureCellBlock = ^(PFCommonTableViewCell * cell, NSDictionary * rssPost) {
        cell.titleLabel.text = [rssPost objectForKey:RSS_POST_TITLE_KEY];
        NSDate * date = [NSDate pfDateFromRfc822String:[rssPost objectForKey:RSS_POST_PUBLISH_DATE_KEY]];
        cell.descriptionLabel.text = [NSString pfMediumDateStringFromDate:date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    TableViewCellSelectBlock selectBlock = ^(NSIndexPath * indexPath, NSDictionary * rssPost) {
        [self performSegueWithIdentifier:@"newsToPostDetailsSegue" sender:self];
    };
    
    self.rssPostsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.rssPosts
                                                             cellIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]
                                                         configureCellBlock:configureCellBlock
                                                            selectCellBlock:selectBlock];
    self.tableView.dataSource = self.rssPostsArrayDataSource;
    self.tableView.delegate = self.rssPostsArrayDataSource;
    
    // hide extra rows
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)fetchRssPosts {
    @weakify(self)
    
    [self showBarberPole];

    // Fetch posts from RSS feed ...
    [[PFRSSHTTPRequestOperationManager sharedManager] getRssPostsWithParameters:nil
                                                                   successBlock:^(AFHTTPRequestOperation *operation, NSXMLParser * xmlParser) {
                                                                       @strongify(self)
                                                                       xmlParser.delegate = self;
                                                                       [xmlParser parse];
                                                                       [self hideBarberPole];
                                                                   }
                                                                   failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                       [UIAlertView pfShowWithTitle:@"Request Failed" message:error.localizedDescription];
                                                                       [self hideBarberPole];
                                                                   }];
}

#pragma mark - NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.rssPosts = [NSMutableArray new];
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    DDLogVerbose(@"didStartElement: %@", elementName);
    
    self.currentElementName = elementName;
    
    if ( [elementName isEqualToString:@"item"] ) {
        self.rssPost = [NSMutableDictionary new];
        return;
    }
    
    self.currentFoundCharacters = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    DDLogVerbose(@"didEndElement: %@", elementName);

    // add rss post to array
    if ( [elementName isEqualToString:@"item"] ) {
        [self.rssPosts addObject:self.rssPost];
        return;
    }

    // set new 'found characters' strings on dictionary
    if ( [elementName isEqualToString:@"title"] ||
        [elementName isEqualToString:@"link"] ||
        [elementName isEqualToString:@"description"] ||
        [elementName isEqualToString:@"pubDate"]) {
        [self.rssPost setObject:self.currentFoundCharacters forKey:elementName];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // ignore new lines, returns
    if ( ! [string isEqualToString:@"\r"] &&
        ! [string isEqualToString:@"\n"] &&
        [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        [self.currentFoundCharacters appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    DDLogVerbose(@"parserDidEndDocument");
    [self setupTableView];
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary * rssPost = [self.rssPostsArrayDataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    ((PFPostDetailsViewController *)segue.destinationViewController).rssPost = rssPost;
}


@end
