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
#import "PFArticleCollectionViewCell.h"
#import "PFAnalyticsManager.h"
#import "PFRSSPost.h"

static const int __unused ddLogLevel = LOG_LEVEL_INFO;

@interface PFNewsViewController () <UITableViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray * rssPosts;
@property (strong, nonatomic) PFRSSPost * rssPost;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

// nasty xml parsing
@property (strong, nonatomic) NSString * currentElementName;
@property (strong, nonatomic) NSMutableString * currentFoundCharacters;

@end

@implementation PFNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
    [self setUpCollectionView];
    [self fetchRssPosts];
    
    @weakify(self);
    self.refreshBlock = ^(){
        @strongify(self);
        [self fetchRssPosts];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"RSS News Screen";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // track selected post and seque to post details
    NSIndexPath * selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    PFRSSPost * rssPost = [self.rssPosts objectAtIndex:selectedIndexPath.row];
    NSString * postURL = rssPost.link;
    [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_SELECTED_RSS_POST_ACTION label:postURL value:nil];
    
    // segue to post details
    ((PFPostDetailsViewController *)segue.destinationViewController).rssPost = rssPost;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // width factor is how wide each cell should be
    // by default it should be half the size of the screen
    CGFloat widthFactor = IPHONE_COLLECTION_VIEW_CELL_WIDTH_FACTOR;
    
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        widthFactor = IPAD_COLLECTION_VIEW_CELL_WIDTH_FACTOR;
    }
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.collectionView.frame) * widthFactor, COLLECTION_VIEW_CELL_HEIGHT);
    return size;
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rssPosts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFArticleCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PFArticleCollectionViewCell pfCellReuseIdentifier] forIndexPath:indexPath];
    
    // configure cell
    PFRSSPost * rssPost = [self.rssPosts objectAtIndex:indexPath.row];
    cell.titleLabel.text = rssPost.title;
    cell.dateLabel.text = [NSString pfMediumDateStringFromDate:rssPost.date];
    cell.excerptLabel.text = rssPost.excerpt;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"newsToPostDetailsSegue" sender:self];
}


#pragma mark - Private methods

- (void)setUpCollectionView {
    [self.collectionView registerNib:[PFArticleCollectionViewCell pfNib]
          forCellWithReuseIdentifier:[PFArticleCollectionViewCell pfCellReuseIdentifier]];
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
    
    if ( [elementName isEqualToString:RSS_POST_ITEM_KEY] ) {
        self.rssPost = [PFRSSPost new];
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
    if ( [elementName isEqualToString:RSS_POST_ITEM_KEY] ) {
        [self.rssPosts addObject:self.rssPost];
        return;
    }
    
    // set new 'found characters' strings on dictionary
    if ( [elementName isEqualToString:RSS_POST_TITLE_KEY]) {
        self.rssPost.title = [self.currentFoundCharacters pfStringByConvertingHTMLToPlainText];
        
    } else if ( [elementName isEqualToString:RSS_POST_LINK_KEY] ) {
        self.rssPost.link = self.currentFoundCharacters;
        
    } else if ( [elementName isEqualToString:RSS_POST_DESCRIPTION_KEY] ) {
        NSString * htmlContent = self.currentFoundCharacters;
        NSString * noHtmlContent = [self.currentFoundCharacters pfStringByConvertingHTMLToPlainText];
        NSString * excerpt = (noHtmlContent.length < 120) ? noHtmlContent : [noHtmlContent substringWithRange:NSMakeRange(0, 120)];
        self.rssPost.content = htmlContent;
        self.rssPost.excerpt = [NSString stringWithFormat:@"%@ ...", excerpt];

    } else if ( [elementName isEqualToString:RSS_POST_PUBLISH_DATE_KEY] ) {
        NSString * dateString =  self.currentFoundCharacters;
        NSDate * date = [NSDate pfDateFromRfc822String:dateString];
        self.rssPost.date = date;
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
    [self.collectionView reloadData];
}

@end
