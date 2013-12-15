//
//  LoginViewController.h
//  IPetChat
//
//  Created by king star on 13-12-14.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *weiboLoginButton;

- (IBAction)loginWithWeibo:(id)sender;
- (void)ssoLoginReturn:(WBBaseResponse *)response;
@end
