//
//  FileUploadInfo.h
//  BackgroundTransfer
//
//  Created by feixiang on 17/6/14.
//  Copyright (c) 2014 feixiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUploadInfo : NSObject


@property (nonatomic, strong) NSString *fileTitle;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSURLSessionUploadTask *task;

// 保存暂停中的任务信息
@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double progress;

@property (nonatomic) BOOL isDoing;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

- (id)initWithFileTitle:(NSString *)title andFilePath:(NSString *)filePath;



@end
