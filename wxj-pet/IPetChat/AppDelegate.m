//
//  AppDelegate.m
//  IPetChat
//
//  Created by XF on 13-11-7.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "AppDelegate.h"
#import "CommunityViewController.h"
#import "SettingViewController.h"
#import "LoginViewController.h"
#import "UrlConfig.h"
#import "CommonToolkit/CommonToolkit.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "DeviceManager.h"
#import "UserBean+Device.h"
#import "Constant.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@interface WBBaseRequest ()
- (void)debugPrint;
@end

@interface WBBaseResponse ()
- (void)debugPrint;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize loginViewController = _loginViewController;
- (void)dealloc
{
    [_window release];
    [_loginViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self loadAccount];
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    //    CommunityViewController *ctrl3 = [[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil] autorelease];
    //    UINavigationController *nav3 = [[[UINavigationController alloc] initWithRootViewController:ctrl3] autorelease];
    //    nav3.navigationBar.tintColor = [UIColor colorWithRed:(77/255.0) green:(78/255.0) blue:(78/255.0) alpha:1];
    //    SettingViewController *ctrl4 = [[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil] autorelease];
    //    UINavigationController *nav4 = [[[UINavigationController alloc] initWithRootViewController:ctrl4] autorelease];
    //    nav4.navigationBar.tintColor = [UIColor colorWithRed:(77/255.0) green:(78/255.0) blue:(78/255.0) alpha:1];
    
    //    UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
    //    tabBarController.viewControllers = [NSArray arrayWithObjects:nav3, nav4, nil];
    
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.loginViewController = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    
    //if not logged in
    self.window.rootViewController = [[AppRootViewController alloc] initWithNavigationViewController:self.loginViewController andBarStyle:UIBarStyleBlack];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    [[DeviceManager shareDeviceManager] stopTimeSync];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    [[DeviceManager shareDeviceManager] startTimeSync];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    NSString *urlStr = [url description];
    NSLog(@"openurl: %@ ctrl:%@", [url description], self.loginViewController);
    if ([urlStr hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    } else if ([urlStr hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    NSString *urlStr = [url description];
    if ([urlStr hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return NO;
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"didReceiveWeiboRequest");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        [self.loginViewController ssoLoginReturn:response];
    }
    
}


- (void)loadAccount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UserBean *user = [[UserBean alloc] init];
    user.name = [userDefaults objectForKey:USERNAME];
    user.userKey = [userDefaults objectForKey:USERKEY];
    NSString *jsonPetInfo = [userDefaults objectForKey:PETINFO];
    if (jsonPetInfo) {
        NSDictionary *petInfoDic = [jsonPetInfo objectFromJSONString];
        PetInfo *petInfoBean = [[PetInfo alloc] init];
        petInfoBean.petId = [petInfoDic objectForKey:PETID];
        petInfoBean.avatar = [petInfoDic objectForKey:AVATAR];
        petInfoBean.nickname = [petInfoDic objectForKey:NICKNAME];
        petInfoBean.sex = [petInfoDic objectForKey:SEX];
        petInfoBean.breed = [petInfoDic objectForKey:BREED];
        petInfoBean.birthday = [petInfoDic objectForKey:BIRTHDAY];
        petInfoBean.height = [petInfoDic objectForKey:HEIGHT];
        petInfoBean.weight = [petInfoDic objectForKey:WEIGHT];
        petInfoBean.deviceno = [petInfoDic objectForKey:DEVICEID];
        user.petInfo = petInfoBean;
    }
    [[UserManager shareUserManager] setUserBean:user];
}


@end
