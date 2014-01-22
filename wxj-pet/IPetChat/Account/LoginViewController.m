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
#import "PetInfo.h"
#import "UserBean+Device.h"
#import "PrintObject.h"

@interface LoginViewController () {
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
}
- (void)thirdLogin:(NSString *)identifier;
- (void)onFinishedThirdLogin:(ASIHTTPRequest*)pRequest;

- (void)queryPetInfo;
@end

@implementation LoginViewController
@synthesize weiboLoginButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _permissions = [NSArray arrayWithObjects:
                         kOPEN_PERMISSION_GET_USER_INFO,
                         kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                         nil];

        
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:TencentAppId
                                                andDelegate:self];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
    
    if (![self needLogin]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        [hud setLabelText:@"登录中…"];
        [hud showWhileExecuting:@selector(queryPetInfo) onTarget:self withObject:nil animated:YES];
//        [self queryPetInfo];
        
//        [self jumpToMainPage];
    }
    
}

- (BOOL)needLogin {
    BOOL ret = YES;
    UserBean *user = [[UserManager shareUserManager] userBean];
    if (user != nil && user.userKey != nil && ![user.userKey isEqualToString:@""]) {
        // jump to main page directly
        ret = NO;
    }
    return ret;
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

- (void)loginWithQQ:(id)sender {
    [_tencentOAuth authorize:_permissions inSafari:NO];
}

- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken
        && 0 != [_tencentOAuth.accessToken length])
    {
        NSString *openId = _tencentOAuth.openId;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        [hud setLabelText:NSLocalizedString(@"Processing", @"正在处理中")];
        [hud showWhileExecuting:@selector(thirdLogin:) onTarget:self withObject:openId animated:YES];
        
    }
    else
    {
        // qq login failed
        NSString *title = NSLocalizedString(@"QQ SSO Result", @"QQ认证结果");
        NSString *message = NSLocalizedString(@"SSO Login failed", @"SSO 登录失败");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSString *title = NSLocalizedString(@"QQ SSO Result", @"QQ认证结果");
    NSString *message = NSLocalizedString(@"SSO Login failed", @"SSO 登录失败");
    if (cancelled) {
        message = NSLocalizedString(@"Login Cancelled", @"登录被取消");
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                          otherButtonTitles:nil];
    
    [alert show];

}

- (void)tencentDidNotNetWork {
    NSString *title = NSLocalizedString(@"QQ SSO Result", @"QQ认证结果");
    NSString *message = NSLocalizedString(@"Network Error", @"网络不可用");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                          otherButtonTitles:nil];
    
    [alert show];
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
            NSLog(@"json data: %@", jsonData);
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
                 
                    [self queryPetInfo];
                    
//                    // jump to main view
//                    [self jumpToMainPage];
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

- (void)jumpToMainPage {
     [self.navigationController pushViewController:[[MainTabController alloc] init] animated:NO];
}

- (void)queryPetInfo {
    UserBean *user = [[UserManager shareUserManager] userBean];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [HttpUtils postSignatureRequestWithUrl:GET_PET_LIST_URL andPostFormat:urlEncoded andParameter:param andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onGetPetInfoListFinished:) andFailedRespSelector:nil];
}

- (void)onGetPetInfoListFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onGetPetInfoListFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"json data: %@", jsonData);
            if (jsonData) {
                NSArray *list = [jsonData objectForKey:LIST];
                if (list && [list count] > 0) {
                    NSDictionary *petInfo = [list objectAtIndex:0];
                    PetInfo *petBean = [[PetInfo alloc] init];
                    petBean.petId = [petInfo objectForKey:PETID];
                    petBean.avatar = [petInfo objectForKey:AVATAR];
                    petBean.nickname = [petInfo objectForKey:NICKNAME];
                    petBean.sex = [petInfo objectForKey:SEX];
                    petBean.breed = [petInfo objectForKey:BREED];
                    petBean.birthday = [petInfo objectForKey:BIRTHDAY];
                    petBean.height = [petInfo objectForKey:HEIGHT];
                    petBean.weight = [petInfo objectForKey:WEIGHT];
                    petBean.area = [petInfo objectForKey:DISTRICT];
                    petBean.placeOftenGo = [petInfo objectForKey:PLACEOFTENGO];
                    petBean.deviceno = [petInfo objectForKey:DEVICEID];
                    
                    if (petBean.area == nil) {
                        petBean.area = @"";
                    }
                    if (petBean.placeOftenGo == nil) {
                        petBean.placeOftenGo = @"";
                    }
                    
                    NSString *devicePwd = [petInfo objectForKey:DEVICEPWD];
                  
                    
                    UserBean *user = [[UserManager shareUserManager] userBean];
                 
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    if (devicePwd != nil) {
                        user.devicePassword = devicePwd;
                        [userDefaults setObject:user.devicePassword forKey:DEVICEPWD];
                    }
                    
                    user.petInfo = petBean;
                    NSData *petInfoData = [PrintObject getJSON:petBean options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonPetInfo = [[NSString alloc] initWithData:petInfoData encoding:NSUTF8StringEncoding];
                    
                   
                    [userDefaults setObject:jsonPetInfo forKey:PETINFO];
                  
                }
            }
        }
    }
    
    // jump to main view
    [self jumpToMainPage];

}

@end
