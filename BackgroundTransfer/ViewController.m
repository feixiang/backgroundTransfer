//
//  ViewController.m
//  BackgroundTransfer
//
//  Created by feixiang on 16/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "FileDownloadInfo.h"
#import "FileUploadInfo.h"
#import "AppDelegate.h"

// Define some constants regarding the tag values of the prototype cell's subviews.
#define CellLabelTagValue               10
#define CellStartPauseButtonTagValue    20
#define CellStopButtonTagValue          30
#define CellProgressBarTagValue         40
#define CellLabelReadyTagValue          50


@interface ViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionUploadTask *task;
@property (nonatomic) BOOL isDoing;

@property (nonatomic, strong) NSMutableArray *arrUploadList;
// 文件存放地址
@property (nonatomic, strong) NSString *documentsDirectory;

@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSString *fileParam;
@property (nonatomic, strong) NSURL *uploadURL;
@property (nonatomic, strong) NSNumber *currentIndex;

@end

@implementation ViewController


- (void)initUploadList{
    self.arrUploadList = [[NSMutableArray alloc] init];
    NSArray *fileList = [self getFiles:self.documentsDirectory];
    
    for(NSString* file in fileList)
    {
        NSString* filePath = [self getFilePath:file];
        [self.arrUploadList addObject:[[FileUploadInfo alloc] initWithFileTitle:file andFilePath:filePath]];
    }
    
}	


// 继承tableview的函数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrUploadList.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell"];
    if( cell == nil ){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCell" ];
    }
    FileUploadInfo *uploader = [self.arrUploadList objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell viewWithTag:CellLabelTagValue];
    // 设置属性
    title.text = uploader.fileTitle;
    return cell ;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.isDoing = NO ;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    self.tblFiles.delegate = self ;
    self.tblFiles.dataSource = self ;
    
    [self initUploadList];
    [self BgUploadInitSession];
    
}


// -------------<feixiang>后台传输函数----------

- (void)BgUploadInitSession{
    // 这里加入后台下载功能
    // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.yuanfang"];
    // 后台下载用 backgroundSessionConfiguration，先用默认的设置
    //NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    
    // 初始化上传地址
    self.boundary = @"----------V2ymHFg03ehbqgZCaKO6jy" ;
    self.uploadURL = [NSURL URLWithString:@"http://cloud1.yfway.com/OpenAPI/?s=Task/Upload/"];

}

- (NSMutableURLRequest *)BgUploadSetHeader{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.uploadURL];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    return request ;
}

- (NSURL *)BgUploadSetUrl:(NSString *)uploadFilePath{
    NSData *body = [self BgUploadPrepareData:uploadFilePath] ;
    NSString* uploadFile_tmp = [NSString stringWithFormat:@"%@_tmp" ,uploadFilePath ];
    [body writeToFile:uploadFile_tmp atomically:true];
    
    // 上传完成后需要将临时文件删除
    NSString *filePath = [[NSString stringWithFormat:@"file://%@", uploadFile_tmp] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileUrl =  [NSURL URLWithString:filePath];
    
    return fileUrl;
}

// 这里删除文件有点问题
- (void)BgUploadRemoveTmpFile:(NSString *)tmpFilepath{
    tmpFilepath = [NSString stringWithFormat:@"%@_tmp",tmpFilepath];
    tmpFilepath = [[NSString stringWithFormat:@"file://%@", tmpFilepath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSFileManager *defaultManager;
    defaultManager = [NSFileManager defaultManager];
    NSError *error ;
    BOOL ret = [defaultManager removeItemAtPath:tmpFilepath error:&error];
    if( ret == NO )
        NSLog(@"\nerror:%@",error);
}

- (NSData*) BgUploadPrepareData:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    
    NSMutableData *body = [NSMutableData data];
    if( fileExists == YES ){
        NSString *fileName = [filePath lastPathComponent];
        
        NSData *dataOfFile = [[NSData alloc] initWithContentsOfFile:filePath];
        
        // 组装POST格式
        if (dataOfFile) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:dataOfFile];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return body;
}

- (void)BgUploadCommon:(NSString *)uploadFilePath{
    // 由于fromFile会覆盖原来的http请求的body内容。可以先构造一个request，然后将body信息存到文件里面，提供给task调用
    // 1 ， 构造 HTTP Request POST HEADER
    NSMutableURLRequest *request = [self BgUploadSetHeader];
    // 2 , 将文件和保存文件form-data信息一起保存到磁盘临时文件中
    NSURL *fileUrl = [self BgUploadSetUrl:uploadFilePath];
    // 3，使用task的fromFile上传函数
    self.task = [self.session uploadTaskWithRequest:request fromFile:fileUrl];
    // 启动后台任务，下面回调函数接收消息
    [self.task resume];
}
// ----------end 后台传输--------


//----------------各个按钮事件
- (IBAction)startAll:(id)sender{
    if( self.isDoing == NO ){
        [self.buttonStart setTitle:@"STOP" forState:UIControlStateHighlighted];
        self.isDoing = YES;
    }else{
        [self.buttonStart setTitle:@"START" forState:UIControlStateHighlighted];
        self.isDoing = NO;
    }
    FileUploadInfo *uploader = [self.arrUploadList objectAtIndex:0];
    [self BgUploadCommon:uploader.filePath];
}
- (IBAction)stopUpload:(id)sender{
    if( self.task.state == NSURLSessionTaskStateRunning ){
         [self.task suspend];
    }
}
- (IBAction)resumeUpload:(id)sender{
    if( self.task.state == NSURLSessionTaskStateRunning ){
        [self.task resume];
    }
}

- (IBAction)cancelUpload:(id)sender{
    if( self.task.state == NSURLSessionTaskStateRunning ){
        [self.task cancel];
    }
}





//----------------NSURLSession回调函数-------------------------
// 上传进度中
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"\n%f / %f", (double)totalBytesSent,
          (double)totalBytesExpectedToSend);
    
    // 更新界面
    //int index = [self getIndexWithTaskIdentifier:task.taskIdentifier];
    int index = [self.currentIndex intValue];
    FileUploadInfo *uploader = [self.arrUploadList objectAtIndex:index];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        uploader.progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        
        UITableViewCell *cell = [self.tblFiles cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
        progressView.progress = uploader.progress;
    }];
}

// 上传完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    // 这里继续做下一个任务
    [self BgUploadBeginNextTask];
}

- (void)BgUploadBeginNextTask{
    //int index = [self getIndexWithTaskIdentifier:task.taskIdentifier] + 1 ;
    self.currentIndex = @([self.currentIndex intValue] + 1 );
    int index = [self.currentIndex intValue];
    FileUploadInfo *uploader = [self.arrUploadList objectAtIndex:index];
    
    NSLog(@"\n第 %@ 个任务 %@ 完成 ",self.currentIndex, uploader.filePath);
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"%@ have been uploaded!",uploader.filePath];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    
    //先删除临时文件
    [self BgUploadRemoveTmpFile:uploader.filePath];
    if( index < [self.arrUploadList count] ){
        [self BgUploadCommon:uploader.filePath];
    }
}

// 后台传输完成，处理URLSession完成事件
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([uploadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler();
                    
                    // 这里继续做下一个任务
                    [self BgUploadBeginNextTask];
                }];
            }
        }
        
        
    }];
}

-(int)getIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    for (int i=0; i<[self.arrUploadList count]; i++) {
        FileUploadInfo *uploader = [self.arrUploadList objectAtIndex:i];
        if (uploader.taskIdentifier == taskIdentifier) {
            index = i;
            break;
        }
    }
    
    return index;
}

//----------------END NSURLSession回调函数-----------------------




// 获取目录下的所有文件
-(NSArray*)getFiles:(NSString *)dir
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* array = [fm contentsOfDirectoryAtPath:dir error:nil ];
    NSMutableArray* fileList = [[NSMutableArray alloc]init];
    
    BOOL isDir = NO ;
    for(NSString* file in array)
    {
        [fm fileExistsAtPath:file isDirectory:&isDir];
        if( !isDir && ![file isEqualToString:@".DS_Store"])
            [fileList addObject:file];
    }
    return fileList ;
}



- (NSString*)getFilePath:(NSString *)filename{
    NSString *uploadFilePath = [self.documentsDirectory stringByAppendingPathComponent:filename];
    return uploadFilePath;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
