//
//  PFFileDownloadManager.m
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import "PFFileDownloadManager.h"
#import "AFNetworking/AFURLSessionManager.h"

static const int __unused ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PFFileDownloadManager()

// filesDictionary is a hash of the files in the Documents directory. Key = file names, Value = full path to the file
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
        // create cache dictionary
        [self loadFiles];
    }
    return self;
}

#pragma mark - Private methods

- (void)loadFiles {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectoryPath = [paths objectAtIndex:0];
    NSError * error = nil;
    NSArray * documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectoryPath error:&error];

    self.filesDictionary = [NSMutableDictionary dictionary];
    [documents enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
        [self.filesDictionary setObject:[documentDirectoryPath stringByAppendingPathComponent:fileName] forKey:fileName];
    }];
}

#pragma mark - Public methods

- (void)downloadFileWithURL:(NSURL *)URL withCompletion:(void (^)(NSURL * fileURL, NSError * error))completion {
    
    // check cache
    NSString * fileName = [URL lastPathComponent];
    NSString * filePath = [self.filesDictionary objectForKey:fileName];
    if ( filePath ) {
        DDLogVerbose(@"cached file found: %@", filePath);
        NSURL * URL = [NSURL fileURLWithPath:filePath];
        completion(URL, nil);
        return;
    }
    
    // file did not exist in cache
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                      NSError * error = nil;
                                                                      NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                                            inDomain:NSUserDomainMask
                                                                                                                                   appropriateForURL:nil
                                                                                                                                              create:NO
                                                                                                                                               error:&error];
                                                                      if ( error ) {
                                                                          // documents directory is inaccessible?
                                                                          completion(nil, error);
                                                                          return nil;
                                                                      }
                                                                      
                                                                      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                  } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                                                                      if ( error ) {
                                                                          completion(nil, error);
                                                                          return;
                                                                      }
                                                                      completion(filePath, nil);
                                                                      
                                                                      DDLogVerbose(@"File [%@] downloaded to: %@", response.suggestedFilename, filePath);
                                                                  }];
    [downloadTask resume];
}

@end
