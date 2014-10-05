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

@interface PFDocumentsViewController () <UITableViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * documents;
@property (strong, nonatomic) PFEditableArrayDataSource * documentsArrayDataSource;
@property (strong, nonatomic) UIDocumentInteractionController * documentInteractionController;
@property (strong, nonatomic) UIBarButtonItem * editButton;
@property (strong, nonatomic) UIView * noDocumentsView;

@end

@implementation PFDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Documents";
    [self setUpTableView];
    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)viewWillAppear:(BOOL)animated {
    self.screenName = @"Documents Screen";
    
    self.documents = [[PFFileDownloadManager sharedManager] files];
    
    [self toggleTableView];
    
    // bring table view to front
    [self.view bringSubviewToFront:self.tableView];
    
    [self.documentsArrayDataSource reloadItems:self.documents];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


#pragma mark UIDocumentInteractionControllerDelegate methods

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
        
        // Fire up the document interaction controller
        if ( self->_documentInteractionController == nil ) {
            self->_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            self->_documentInteractionController.delegate = self;
        }
        
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
            self.noDocumentsView = [[NSBundle mainBundle] pfFindObjectInNibNamed:@"NoDocumentsView" owner:self byClass:([UIView class])];
            self.noDocumentsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            [self.view addSubview:self.noDocumentsView];
        }
        
        // bring no documents view to the front
        [self.view bringSubviewToFront:self.noDocumentsView];
    }
    else {
        [self.view sendSubviewToBack:self.noDocumentsView];
    }
}

@end
