//
//  PFPostDetailsViewController.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 5/24/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFPostDetailsViewController.h"
#import "PFHTTPRequestOperationManager.h"

@interface PFPostDetailsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation PFPostDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ( [self respondsToSelector:@selector(edgesForExtendedLayout)] ) { 
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"Post";
    [self fetchPost];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchPost {
    
    @weakify(self)

    // Fetch posts from blog ...
    [[PFHTTPRequestOperationManager sharedManager] getPostWithId:self.postID
                                                      parameters:nil
                                                    successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                 @strongify(self)
                                                                 if ( [responseObject isKindOfClass:([NSDictionary class])] ) {
                                                                     NSDictionary * response = (NSDictionary *)responseObject;
                                                                     self.titleLabel.text = [response objectForKey:@"title"];
                                                                     self.dateLabel.text = [response objectForKey:@"date"];
                                                                     self.contentTextView.text = [response objectForKey:@"content"];
                                                                 }
                                                             }
                                                             failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                 NSException * exception = [[NSException alloc] initWithName:@"HTTP Operation Failed" reason:error.localizedDescription userInfo:nil];
                                                                 [exception raise];
                                                             }];
}

@end
