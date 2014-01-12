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
@synthesize colorLabel;
@synthesize heightLabel;
@synthesize weightLabel;
@synthesize areaLabel;
@synthesize placeOftenGoLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    if (petInfo) {
        [self.avatarImageView setImageURL:[NSString stringWithFormat:@"%@/%@", IMAGE_GET_ADDR, petInfo.avatar]];
        [self.nicknameLabel setText:petInfo.nickname];
        
        [self.breedLabel setText:[PetInfoUtil getBreedByType:petInfo.breed]];
        [self.ageLabel setText:[[PetInfoUtil getAgeByBirthday:petInfo.birthday] stringValue]];
        [self.heightLabel setText:[NSString stringWithFormat:@"%@cm", petInfo.height]];
        [self.weightLabel setText:[NSString stringWithFormat:@"%@g", petInfo.weight]];
        [self.areaLabel setText:petInfo.area];
        [self.placeOftenGoLabel setText:petInfo.placeOftenGo];
    }
}

- (void)locatePet:(id)sender {
    // todo: jump to location map
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
    [self setAvatarImageView:nil];
    [self setNicknameLabel:nil];
    [self setPowerProgressView:nil];
    [self setPowerLabel:nil];
    [self setMotionScoreProgressView:nil];
    [self setMotionScoreLabel:nil];
    [self setBreedLabel:nil];
    [self setAgeLabel:nil];
    [self setColorLabel:nil];
    [self setHeightLabel:nil];
    [self setWeightLabel:nil];
    [self setAreaLabel:nil];
    [self setPlaceOftenGoLabel:nil];
    [super viewDidUnload];
}
@end
