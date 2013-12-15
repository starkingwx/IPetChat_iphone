//
//  LoginViewController.m
//  IPetChat
//
//  Created by king star on 13-12-14.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "LoginViewController.h"
#import "UrlConfig.h"
#import "CommonToolkit/CommonToolkit.h"
#import "Constant.h"
#import "MainTabController.h"

@interface LoginViewController ()
- (void)thirdLogin:(NSString *)identifier;
- (void)onFinishedThirdLogin:(ASIHTTPRequest*)pRequest;
@end

@implementation LoginViewController
@synthesize weiboLoginButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWeiboLoginButton:nil];
    [super viewDidUnload];
}

#pragma mark - function implementation
- (void)loginWithWeibo:(id)sender {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
//    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
//                         @"Other_Info_1": [NSNumber numberWithInt:123],
//                         @"Other_Info_2": @[@"obj1", @"obj2"],
//                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (void)ssoLoginReturn:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if (response.statusCode == 0) {
            // sso login success
            NSString *userId = [(WBAuthorizeResponse *)response userID];
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
            [hud setLabelText:NSLocalizedString(@"Processing", @"正在处理中")];
            [hud showWhileExecuting:@selector(thirdLogin:) onTarget:self withObject:userId animated:YES];
        } else {
            // sso login failed
            NSString *title = NSLocalizedString(@"Weibo SSO Result", @"微博认证结果");
            NSString *message = NSLocalizedString(@"SSO Login failed", @"SSO 登录失败");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                                  otherButtonTitles:nil];
            
            
            [alert show];
        }
        
    }

}

- (void)thirdLogin:(NSString *)identifier {
     NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:identifier, @"identifier", nil];
    [HttpUtils postRequestWithUrl:THIRD_LOGIN_URL andPostFormat:urlEncoded andParameter:param andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedThirdLogin:) andFailedRespSelector:nil];
}

- (void)onFinishedThirdLogin:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedThirdLogin - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:RESULT];
                NSLog(@"result: %@", result);
                
                if([result isEqualToString:@"0"]) {
                    // login successfully
                    NSString *userkey = [jsonData objectForKey:USERKEY];
                    NSLog(@"userkey: %@", userkey);
                    NSString *userName = [jsonData objectForKey:USERNAME];
                    
                    
                    // save the account info
                    UserBean *userBean = [[UserManager shareUserManager] userBean];
                    userBean.userKey = userkey;
                    userBean.name = userName;
                    
                    NSLog(@"userbean: %@", userBean.description);
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:userBean.name forKey:USERNAME];
                    [userDefaults setObject:userBean.userKey forKey:USERKEY];
                 
                    // jump to main view
                    [self.navigationController pushViewController:[[MainTabController alloc] init] animated:YES];
                } else {
                    goto login_error;
                }
            } else {
                goto login_error;
            }
            break;
        }
        default:
            goto login_error;
            break;
    }
    
    return;
    
login_error:
    [[[iToast makeText:NSLocalizedString(@"Error in third login, please retry.", "")] setDuration:iToastDurationLong] show];
}

@end
