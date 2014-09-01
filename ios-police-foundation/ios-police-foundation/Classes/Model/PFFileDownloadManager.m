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

    }
    return self;
}

#pragma mark - Public methods

- (void)downloadFileWithURL:(NSURL *)fileUrl withCompletion:(void (^)(NSURL * fileURL, NSError * error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
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
