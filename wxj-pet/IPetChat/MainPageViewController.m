//
//  MainPageViewController.m
//  IPetChat
//
//  Created by king star on 14-1-4.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "MainPageViewController.h"
#import "UserBean+Device.h"
#import "UrlConfig.h"
#import "PetInfoUtil.h"
#import "Constant.h"
#import "PrintObject.h"
#import "LocationMapViewController.h"
#import "DeviceManager.h"

@interface MainPageViewController () {
    AsynImageView *_avatarView;
}

@end

@implementation MainPageViewController
@synthesize avatarImageViewContainer;
@synthesize nicknameLabel;
@synthesize powerProgressView;
@synthesize powerLabel;
@synthesize motionScoreProgressView;
@synthesize motionScoreLabel;
@synthesize breedLabel;
@synthesize ageLabel;
@synthesize heightLabel;
@synthesize weightLabel;
@synthesize areaLabel;
@synthesize placeOftenGoLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Home", @"首页");
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Home", @"") image:[UIImage imageNamed:@"ic_home"] tag:0];
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    [self fillPetInfo:petInfo];
    
//    [self fillDeviceInfo:nil];
    
    [self queryPetInfo];
    [self queryLatestPetDeviceInfo];
}

- (void)fillPetInfo:(PetInfo *)petInfo {
    if (petInfo && petInfo.petId) {
        [_avatarView setImageURL:[NSString stringWithFormat:@"%@/%@", IMAGE_GET_ADDR, petInfo.avatar]];
//        [self.avatarImageViewContainer setImage:[UIImage imageNamed:@"img_petstar"]];
        self.avatarImageViewContainer.hidden = NO;
        [self.nicknameLabel setText:petInfo.nickname];
        
        [self.breedLabel setText:[PetInfoUtil getBreedByType:petInfo.breed]];
        NSNumber *month = [PetInfoUtil getAgeByBirthday:petInfo.birthday];
        if ([petInfo.birthday longLongValue] > 0) {
            NSString *birthdayText = [NSString stringWithFormat:@"%@月", month];
            [self.ageLabel setText:birthdayText];
        } else {
            [self.ageLabel setText:@""];
        }
        if (petInfo.height != nil) {
            [self.heightLabel setText:[NSString stringWithFormat:@"%@厘米", petInfo.height]];      
        } else {
            [self.heightLabel setText:@""];
        }
        if (petInfo.weight) {
            [self.weightLabel setText:[NSString stringWithFormat:@"%@公斤", petInfo.weight]];
        } else {
            [self.weightLabel setText:@""];
        }
        [self.areaLabel setText:petInfo.area];
        [self.placeOftenGoLabel setText:petInfo.placeOftenGo];
    }

}

- (void)queryPetInfo {
    UserBean *user = [[UserManager shareUserManager] userBean];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [HttpUtils postSignatureRequestWithUrl:GET_PET_LIST_URL andPostFormat:urlEncoded andParameter:param andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onGetPetInfoListFinished:) andFailedRespSelector:nil];
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
                    petBean.deviceno = [petInfo objectForKey:DEVICEID];
                    petBean.area = [petInfo objectForKey:DISTRICT];
                    petBean.placeOftenGo = [petInfo objectForKey:PLACEOFTENGO];
                    
                    if (petBean.area == nil) {
                        petBean.area = @"";
                    }
                    if (petBean.placeOftenGo == nil) {
                        petBean.placeOftenGo = @"";
                    }
                    
                    UserBean *user = [[UserManager shareUserManager] userBean];
                    user.petInfo = petBean;
                    NSData *petInfoData = [PrintObject getJSON:petBean options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonPetInfo = [[NSString alloc] initWithData:petInfoData encoding:NSUTF8StringEncoding];
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:jsonPetInfo forKey:PETINFO];
                    [self fillPetInfo:petBean];
                }
            }
        }
    }
}


- (void)locatePet:(id)sender {
    //jump to location map
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    if (petInfo == nil || petInfo.petId == nil) {
        [[iToast makeText:@"请先设置宠物信息！"] show];
        return;
    }
    
    [self.navigationController pushViewController:[[LocationMapViewController alloc] init] animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    CGRect frame = self.avatarImageViewContainer.frame;
    _avatarView = [[AsynImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.avatarImageViewContainer addSubview:_avatarView];
    [_avatarView setPlaceholderImage:[UIImage imageNamed:@"img_petstar"]];
//    [_avatarView setImage:[UIImage imageNamed:@"img_petstar"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAvatarImageViewContainer:nil];
    [self setNicknameLabel:nil];
    [self setPowerProgressView:nil];
    [self setPowerLabel:nil];
    [self setMotionScoreProgressView:nil];
    [self setMotionScoreLabel:nil];
    [self setBreedLabel:nil];
    [self setAgeLabel:nil];
    [self setHeightLabel:nil];
    [self setWeightLabel:nil];
    [self setAreaLabel:nil];
    [self setPlaceOftenGoLabel:nil];
    [_avatarView removeFromSuperview];
    [super viewDidUnload];
}

- (void)queryLatestPetDeviceInfo {
     [[DeviceManager shareDeviceManager] queryLastestInfoWithProcessor:self andFinishedRespSelector:@selector(onQueryFinished:) andFailedRespSelector:nil];
}

- (void)onQueryFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onQueryFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
            
        case 200: {
            // create group and invite ok
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"response data: %@", jsonData);
            if (jsonData) {
                NSString *status = [jsonData objectForKey:STATUS];
                if ([SUCCESS isEqualToString:status]) {
                    NSDictionary *archOp = [jsonData objectForKey:ArchOperation];
                    NSArray *trackSdata = [archOp objectForKey:TRACK_SDATE];
                    if (trackSdata && [trackSdata count] > 0) {
                        NSDictionary *data = [trackSdata objectAtIndex:0];
                        [self fillDeviceInfo:data];
                    }
                }
            } else {
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)fillDeviceInfo:(NSDictionary *)data {
    // set batter power progress
    [self.powerProgressView setProgress:0.5 animated:YES];
    self.powerLabel.text = @"50%";
    
    // set motion point progress
    NSNumber *vitality = [data objectForKey:VITALITY];
    float motionPercentage = [PetInfoUtil calculateAvgMotionPercentage:[vitality longValue]];
    NSInteger point = [PetInfoUtil calculateMotionPoint:[vitality longValue]];
    self.motionScoreLabel.text = [NSString stringWithFormat:@"%d", point];
    [self.motionScoreProgressView setProgress:motionPercentage animated:YES];
}

@end
