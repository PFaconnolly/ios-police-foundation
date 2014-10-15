//
//  PFDocumentsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/7/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFDocumentsViewController.h"
#import "PFEditableArrayDataSource.h"
#import "PFFileDownloadManager.h"
#import "PFCommonTableViewCell.h"
#import "NSBundle+PFExtensions.h"
#import "PFNoDocumentsView.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFDocumentsViewController () <UITableViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * documents;
@property (strong, nonatomic) PFEditableArrayDataSource * documentsArrayDataSource;
@property (strong, nonatomic) UIDocumentInteractionController * documentInteractionController;
@property (strong, nonatomic) UIBarButtonItem * editButton;
@property (strong, nonatomic) PFNoDocumentsView * noDocumentsView;

@end

@implementation PFDocumentsViewController

#pragma mark - View life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Documents";
    [self setUpTableView];    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Documents Screen";
    self.documents = [[PFFileDownloadManager sharedManager] files];
    [self toggleTableView];
    [self.documentsArrayDataSource reloadItems:self.documents];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


#pragma mark - UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}


#pragma mark - Private methods

- (void)setUpTableView {
    [self.tableView registerClass:[PFCommonTableViewCell class] forCellReuseIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    TableViewCellConfigureBlock configureCellBlock = ^(PFCommonTableViewCell * cell, NSDictionary * file) {
        CGFloat bytes = [file fileSize];
        NSDate * creationDate = [file fileCreationDate];
        NSString * fileName = [file objectForKey:PFFileName];
        cell.titleLabel.text = fileName;
        cell.descriptionLabel.text = [NSString stringWithFormat:@"%.02f MB - %@", bytes/1000, [NSString pfShortDateStringFromDate:creationDate]];
    };

    // Selection cell block
    @weakify(self);
    TableViewCellSelectBlock selectCellBlock = ^(NSIndexPath * path, NSDictionary * item) {
        @strongify(self);
        NSString * filePath = [item objectForKey:PFFilePath];
        NSURL * fileURL = [NSURL fileURLWithPath:filePath];
        
        // track the file name that was viewed
        NSString * fileName = [fileURL lastPathComponent];
        [[PFAnalyticsManager sharedManager] trackEventWithCategory:GA_USER_ACTION_CATEGORY action:GA_VIEWED_FILE_NAME_ACTION label:fileName value:nil];
        
        // Fire up the document interaction controller
        if ( self->_documentInteractionController == nil ) {
            self->_documentInteractionController = [[UIDocumentInteractionController alloc] init];
            self->_documentInteractionController.delegate = self;
        }
        
        self->_documentInteractionController.URL = fileURL;
        [self->_documentInteractionController presentPreviewAnimated:YES];
    };
    
    // Item deleted ...
    ItemDeletedBlock itemDeletedBlock = ^(NSUInteger count) {
        [self toggleTableView];
    };
    
    // turn off selection during editing
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    
    // set up table and data source
    self.documentsArrayDataSource = [[PFEditableArrayDataSource alloc] initWithItems:self.documents
                                                                      cellIdentifier:[PFCommonTableViewCell pfCellReuseIdentifier]
                                                                  configureCellBlock:configureCellBlock
                                                                     selectCellBlock:selectCellBlock
                                                                    itemDeletedBlock:itemDeletedBlock];
    
    self.tableView.dataSource = self.documentsArrayDataSource;
    self.tableView.delegate = self.documentsArrayDataSource;
}

- (void)editButtonTapped:(id)sender {
    self.tableView.editing = ! self.tableView.editing;
}

- (void)toggleTableView {
    if ( self.documents.count == 0 ) {
        if ( self.noDocumentsView == nil ) {
            self.noDocumentsView = [[NSBundle mainBundle] pfFindObjectInNibNamed:[PFNoDocumentsView pfNibName] owner:self byClass:([UIView class])];
            //self.noDocumentsView.translatesAutoresizingMaskIntoConstraints = NO;
            self.noDocumentsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            [self.view addSubview:self.noDocumentsView];
        }
        
        // bring no documents view to the front
        self.noDocumentsView.hidden = NO;
        self.tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;

    } else {
        // bring table view to the front
        self.tableView.hidden = NO;
        self.noDocumentsView.hidden = YES;
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

@end
