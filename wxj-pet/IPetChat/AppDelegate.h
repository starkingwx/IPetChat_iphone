//
//  AppDelegate.h
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "WeiboSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) LoginViewController *loginViewController;
@end
