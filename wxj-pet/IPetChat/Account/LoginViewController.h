//
//  LoginViewController.h
//  IPetChat
//
//  Created by king star on 13-12-14.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface LoginViewController : UIViewController <TencentSessionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *weiboLoginButton;

- (IBAction)loginWithWeibo:(id)sender;
- (void)ssoLoginReturn:(WBBaseResponse *)response;
- (IBAction)loginWithQQ:(id)sender;
@end
