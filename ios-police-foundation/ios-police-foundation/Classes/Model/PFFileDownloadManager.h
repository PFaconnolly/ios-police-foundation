//
//  PFFileDownloadManager.h
//  ios-police-foundation
//
//  Created by Aaron Connolly on 9/1/14.
//  Copyright (c) 2014 Police Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString * PFFileName;
extern const NSString * PFFilePath;

@interface PFFileDownloadManager : NSObject

+ (id)sharedManager;

- (NSArray *)files;

// download a file at a given url and stores
- (void)downloadFileWithURL:(NSURL *)fileUrl withCompletion:(void (^)(NSURL * filePath, NSError * error))completion;

@end
