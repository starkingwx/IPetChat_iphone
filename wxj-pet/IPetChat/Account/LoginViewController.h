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

@interface LoginViewController : UIViewController <TencentSessionDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *weiboLoginButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameInput;
@property (strong, nonatomic) IBOutlet UITextField *pwdInput;

- (IBAction)loginWithWeibo:(id)sender;
- (void)ssoLoginReturn:(WBBaseResponse *)response;
- (IBAction)doLoginWithSegoId:(id)sender;
- (IBAction)loginWithQQ:(id)sender;
@end
