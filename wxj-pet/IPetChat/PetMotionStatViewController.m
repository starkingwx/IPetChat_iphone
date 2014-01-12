//
//  PetMotionStatViewController.m
//  IPetChat
//
//  Created by king star on 14-1-5.
//  Copyright (c) 2014年 XF. All rights reserved.
//

#import "PetMotionStatViewController.h"
#import "UserBean+Device.h"
#import "UrlConfig.h"
#import "PetInfoUtil.h"

@interface PetMotionStatViewController ()

@end

@implementation PetMotionStatViewController

@synthesize avatarImageView;
@synthesize nicknameLabel;
@synthesize usageCountLabel;
@synthesize breedLabel;
@synthesize ageLabel;
@synthesize heightLabel;
@synthesize weightLabel;


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
    }
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
    [self setBreedLabel:nil];
    [self setAgeLabel:nil];
    [self setHeightLabel:nil];
    [self setWeightLabel:nil];
    [self setUsageCountLabel:nil];
    [super viewDidUnload];
}
- (IBAction)selectTodayStat:(id)sender {
}

- (IBAction)selectHistoryStat:(id)sender {
}
@end
