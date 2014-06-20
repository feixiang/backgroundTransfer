//
//  AppDelegate.h
//  BackgroundTransfer
//
//  Created by feixiang on 16/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();


@end
