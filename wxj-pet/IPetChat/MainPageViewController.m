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

@interface MainPageViewController ()

@end

@implementation MainPageViewController
@synthesize avatarImageView;
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
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    [self fillPetInfo:petInfo];
    
    [self queryPetInfo];
}

- (void)fillPetInfo:(PetInfo *)petInfo {
    if (petInfo) {
//        [self.avatarImageView setImageURL:[NSString stringWithFormat:@"%@/%@", IMAGE_GET_ADDR, petInfo.avatar]];
        [self.avatarImageView setImage:[UIImage imageNamed:@"img_petstar"]];
        [self.nicknameLabel setText:petInfo.nickname];
        
        [self.breedLabel setText:[PetInfoUtil getBreedByType:petInfo.breed]];
        [self.ageLabel setText:[[PetInfoUtil getAgeByBirthday:petInfo.birthday] stringValue]];
        [self.heightLabel setText:[NSString stringWithFormat:@"%@cm", petInfo.height]];
        [self.weightLabel setText:[NSString stringWithFormat:@"%@g", petInfo.weight]];
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
    // todo: jump to location map
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.avatarImageView setPlaceholderImage:[UIImage imageNamed:@"img_petstar"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAvatarImageView:nil];
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
    [super viewDidUnload];
}
@end
