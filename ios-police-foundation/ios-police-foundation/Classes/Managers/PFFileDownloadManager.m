//
//  PFFileDownloadManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/16/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFFileDownloadManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFFileDownloadManager()

@property (strong, nonatomic) NSMutableDictionary * filesDictionary;

@end

@implementation PFFileDownloadManager

+ (id)sharedManager {
    static PFFileDownloadManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (PFFileDownloadManager *)init {
    self = [super init];
    if ( self ) {
        [self loadFiles];
    }
    return self;
}

#pragma mark - Public methods

- (NSArray *)files {
    return self.files;
}

- (void)downloadFileWithURL:(NSURL *)fileUrl fileId:(NSInteger)fileId {
    
}

- (void)openFileWithId:(NSInteger)fileId {
    
}

#pragma mark - Private methods

// reads file names from documents/attachments directory into memory
- (void)loadFiles {
    self.filesDictionary = nil;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [paths objectAtIndex:0];
    NSString * attachmentsDirectoryPath = [documentsPath stringByAppendingPathComponent:@"/attachments"];

    // does /attachments directory exist
    BOOL isDirectory;
    BOOL attachmentsDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:attachmentsDirectoryPath isDirectory:&isDirectory];
    
    if ( ! attachmentsDirectoryExists ) {
        // create directory
        NSError * error = nil;
        BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:attachmentsDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        if ( error ) {
            // do something with error
            DDLogVerbose(@"error creating attachments directory: %@", error.localizedDescription);
            return;
        }
        
        if ( ! directoryCreated ) {
            // also an error do something with directory not created
            DDLogVerbose(@"error: attachments directory not created");
            return;
        }
        
        // assume directory was created
    }
    
    // read file names from /attachments directory
    NSError * error = nil;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:attachmentsDirectoryPath error:&error];
    
    for( NSString * file in directoryContents ) {
        DDLogVerbose(@"file: %@", file);
    }
}


@end
