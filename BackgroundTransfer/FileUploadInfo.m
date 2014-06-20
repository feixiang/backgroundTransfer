//
//  FileUploadInfo.m
//  BackgroundTransfer
//
//  Created by feixiang on 17/6/14.
//  Copyright (c) 2014 feixiang. All rights reserved.
//

#import "FileUploadInfo.h"

@implementation FileUploadInfo

- (id)initWithFileTitle:(NSString *)title andFilePath:(NSString *)filePath{
    if (self == [super init]) {
        self.fileTitle = title;
        self.filePath = filePath;
        self.progress = 0.0;
        self.isDoing = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self ;
}


@end
