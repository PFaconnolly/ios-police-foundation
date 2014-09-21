//
//  PFDocumentsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/7/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFDocumentsViewController.h"
#import "PFArrayDataSource.h"
#import "PFFileDownloadManager.h"
#import "PFDocumentTableViewCell.h"

@interface PFDocumentsViewController () <UITableViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * documents;
@property (strong, nonatomic) PFArrayDataSource * documentsArrayDataSource;
@property (strong, nonatomic) UIDocumentInteractionController * documentInteractionController;
@property (strong, nonatomic) UIBarButtonItem * editButton;
@end

@implementation PFDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Documents";
    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    TableViewCellConfigureBlock configureCellBlock = ^(PFDocumentTableViewCell * cell, NSDictionary * file) {
        CGFloat bytes = [file fileSize];
        NSDate * creationDate = [file fileCreationDate];
        NSString * fileName = [file objectForKey:PFFileName];
        cell.textLabel.text = fileName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f MB - %@", bytes/1000, [NSString pfShortDateStringFromDate:creationDate]];
    };
    
    // turn off selection during editing
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelectionDuringEditing = NO;
    
    // set up table and data source
    self.documentsArrayDataSource = [[PFArrayDataSource alloc] initWithItems:self.documents
                                                              cellIdentifier:@"Cell"
                                                          configureCellBlock:configureCellBlock
                                                             selectCellBlock:nil];
    
    self.tableView.dataSource = self.documentsArrayDataSource;
    [self.tableView registerNib:[PFDocumentTableViewCell nib] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.documents = [[PFFileDownloadManager sharedManager] files];
    self.screenName = @"Documents Screen";
    
    [self.documentsArrayDataSource reloadItems:self.documents];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * document = [self.documentsArrayDataSource itemAtIndexPath:indexPath];
    NSString * filePath = [document objectForKey:PFFilePath];
    NSURL * fileURL = [NSURL fileURLWithPath:filePath];
    
    // Fire up the document interaction controller
    if ( self.documentInteractionController == nil ) {
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.documentInteractionController.delegate = self;
    }

    [self.documentInteractionController presentPreviewAnimated:YES];
}

#pragma mark UIDocumentInteractionControllerDelegate methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.navigationController;
}

#pragma mark - Private methods

- (void)editButtonTapped:(id)sender {
    self.tableView.editing = ! self.tableView.editing;
}

@end
