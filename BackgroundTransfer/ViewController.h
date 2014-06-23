//
//  ViewController.h
//  BackgroundTransfer
//
//  Created by feixiang on 16/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate , UITableViewDataSource , NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblFiles;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;

@property (weak, nonatomic) IBOutlet UIImageView *_imageWithBlock;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)stopUpload:(id)sender;
- (IBAction)resumeUpload:(id)sender;
- (IBAction)startAll:(id)sender;
- (IBAction)cancelUpload:(id)sender;

-(void)UploadTaskWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;


@end
