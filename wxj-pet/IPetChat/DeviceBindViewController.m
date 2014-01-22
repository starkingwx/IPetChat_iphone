//
//  DeviceBindViewController.m
//  IPetChat
//
//  Created by king star on 14-1-19.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "DeviceBindViewController.h"
#import "UserBean+Device.h"
#import "Constant.h"
#import "UrlConfig.h"
#import "PrintObject.h"

@interface DeviceBindViewController ()
- (void)bindDevice;
@end

@implementation DeviceBindViewController

@synthesize deviceIdInput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"设备绑定";
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    if (petInfo == nil || petInfo.deviceno == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"绑定" style:UIBarButtonItemStyleDone target:self action:@selector(bindDevice)];
    } else {
        self.deviceIdInput.text = petInfo.deviceno;
        self.deviceIdInput.enabled = NO;
        self.deviceIdInput.textColor = [UIColor lightGrayColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDeviceIdInput:nil];
    [super viewDidUnload];
}

- (void)bindDevice {
    [self.deviceIdInput resignFirstResponder];
    NSString *deviceno = [self.deviceIdInput text];
    if (deviceno == nil || [deviceno isEqualToString:@""]) {
        [[iToast makeText:@"请输入设备号！"] show];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
    [hud setLabelText:NSLocalizedString(@"Processing", @"正在处理中")];
    [hud showWhileExecuting:@selector(startDeviceBindRequest:) onTarget:self withObject:deviceno animated:YES];
}

- (void)startDeviceBindRequest:(NSString *)deviceno {
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:user.name forKey:USERNAME];
    [param setObject:[petInfo.petId stringValue] forKey:PETID];
    [param setObject:deviceno forKey:@"deviceno"];
    
    [HttpUtils postSignatureRequestWithUrl:BIND_DEVICE_URL andPostFormat:urlEncoded andParameter:param andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedBindDevice:) andFailedRespSelector:nil];
}

- (void)onFinishedBindDevice:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedBindDevice - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"json data: %@", jsonData);
            if (jsonData) {
                NSString *result = [jsonData objectForKey:RESULT];
                if ([@"0" isEqualToString:result]) {
                    [[iToast makeText:@"设备绑定成功！"] show];
                    NSNumber *deviceId = [jsonData objectForKey:@"device_id"];
                    NSString *devicePwd = [jsonData objectForKey:@"device_password"];
                    UserBean *user = [[UserManager shareUserManager] userBean];
                    user.devicePassword = devicePwd;
                    PetInfo *petInfo = user.petInfo;
                    petInfo.deviceno = [deviceId stringValue];
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:devicePwd forKey:DEVICEPWD];
                 
                    NSData *petInfoData = [PrintObject getJSON:petInfo options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonPetInfo = [[NSString alloc] initWithData:petInfoData encoding:NSUTF8StringEncoding];
                    
                    [userDefaults setObject:jsonPetInfo forKey:PETINFO];

                    // disable input
                    self.deviceIdInput.enabled = NO;
                    self.deviceIdInput.textColor = [UIColor lightGrayColor];
                    self.navigationItem.rightBarButtonItem = nil;
                } else if ([@"1" isEqualToString:result]) {
                    [[iToast makeText:@"设备不存在"] show];
                } else if ([@"2" isEqualToString:result]) {
                    [[iToast makeText:@"设备已绑定"] show];
                } else {
                    [[iToast makeText:@"绑定失败"] show];
                }
            } else {
                [[iToast makeText:@"绑定失败"] show];
            }
            
            break;
        }
        default: {
            [[iToast makeText:@"绑定失败"] show];
            break;
        }

    }
}
@end
