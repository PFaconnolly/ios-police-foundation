//
//  PFFileDownloadManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 8/16/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFFileDownloadManager : NSObject

+ (id)sharedManager;

// returns a list of all the files in the ~/documents directory
- (NSArray *)files;

// download a file at a given url and stores
- (void)downloadFileWithURL:(NSURL *)fileUrl fileId:(NSInteger)fileId;

// opens a file with the given Id
- (void)openFileWithId:(NSInteger)fileId;

@end
