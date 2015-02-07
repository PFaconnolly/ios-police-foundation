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

const NSString * PFFileName = @"PFFileName";
const NSString * PFFilePath = @"PFFilePath";

@interface PFFileDownloadManager()

// files array is a list of the files in the Documents directory, ordered by date last modified.
@property (strong, nonatomic) NSMutableArray * filesArray;

// filesDictionary is a hash of the files in the Documents directory. Key = file names, Value = full path to the file
@property (strong, nonatomic) NSMutableDictionary * filesDictionary;

@property (strong, nonatomic) NSString * documentDirectoryPath;

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
    self.documentDirectoryPath = [paths objectAtIndex:0];
    NSError * error = nil;
    NSArray * documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.documentDirectoryPath error:&error];

    // create files dictionary
    self.filesDictionary = [NSMutableDictionary dictionary];
    [documents enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
        [self.filesDictionary setObject:[self.documentDirectoryPath stringByAppendingPathComponent:fileName] forKey:fileName];
    }];
    
    self.filesArray = [NSMutableArray array];
    [documents enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
        NSString * filePath = [self.documentDirectoryPath stringByAppendingPathComponent:fileName];
        NSError * error = nil;
        NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if ( error ) {
            fileAttributes = nil;
            // throw error?
        }
        
        // add file name
        NSMutableDictionary * mutableFileAttributes = [NSMutableDictionary dictionaryWithDictionary:fileAttributes];
        [mutableFileAttributes setObject:fileName forKey:PFFileName];
        [mutableFileAttributes setObject:filePath forKey:PFFilePath];
        [self.filesArray addObject:mutableFileAttributes];
    }];
}

#pragma mark - Public methods

- (NSArray *)files {
    return self.filesArray;
}

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
                                                                      
                                                                      [self loadFiles];
                                                                      
                                                                      DDLogVerbose(@"File [%@] downloaded to: %@", response.suggestedFilename, filePath);
                                                                  }];
    [downloadTask resume];
}

- (void)deleteFileAtPath:(NSString *)filePath withCompletion:(void (^)(NSError * error))completion {
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        completion(nil);
        return;
    }

    NSError * error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    // delete from dictionary
    NSString * fileName = [filePath lastPathComponent];
    [self.filesDictionary removeObjectForKey:fileName];
    
    __block NSInteger removeIndex = -1;
    [self.filesArray enumerateObjectsUsingBlock:^(NSDictionary * file, NSUInteger idx, BOOL *stop) {
        NSString * thisFileName = [file objectForKey:PFFileName];
        if ( [fileName isEqualToString:thisFileName] ) {
            removeIndex = (NSInteger)idx;
            return;
        }
    }];
    
    // delete the object at the index specified if it was found
    if ( removeIndex >= 0 ) [self.filesArray removeObjectAtIndex:removeIndex];
    
    // delete from array
    
    if ( error != nil ) {
        completion(error);
        return;
    }

    completion(nil);
}

@end
