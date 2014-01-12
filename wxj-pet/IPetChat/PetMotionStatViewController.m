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
#import "Constant.h"
#import "PrintObject.h"

@interface PetMotionStatViewController ()
@property (nonatomic) NSMutableArray *slices;
@property (nonatomic) NSArray *sliceColors;
@end

@implementation PetMotionStatViewController

@synthesize avatarImageView;
@synthesize nicknameLabel;
@synthesize usageCountLabel;
@synthesize breedLabel;
@synthesize ageLabel;
@synthesize heightLabel;
@synthesize weightLabel;
@synthesize todayTabBody;
@synthesize historyTabBody;
@synthesize slices;
@synthesize sliceColors;
@synthesize piechart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Motion And Health", @"运动健康");
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Motion And Health", @"") image:[UIImage imageNamed:@"ic_motion"] tag:1];

        self.sliceColors = [NSArray arrayWithObjects:[UIColor colorWithIntegerRed:0 integerGreen:171 integerBlue:223 alpha:1],
                            [UIColor colorWithIntegerRed:166 integerGreen:206 integerBlue:57 alpha:1],
                            [UIColor colorWithIntegerRed:254 integerGreen:194 integerBlue:14 alpha:1],
                            [UIColor colorWithIntegerRed:246 integerGreen:136 integerBlue:32 alpha:1]
                            ,nil];
        
        self.slices = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:52], [NSNumber numberWithInt:35], [NSNumber numberWithInt:10], [NSNumber numberWithInt:3], nil];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    [self fillPetInfo:petInfo];
    [self queryPetInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.piechart reloadData];
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

- (void)fillPetInfo:(PetInfo *)petInfo {
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
    
    self.todayTabBody.hidden = NO;
    self.historyTabBody.hidden = YES;
    
    [self.avatarImageView setPlaceholderImage:[UIImage imageNamed:@"img_petstar"]];
    
    [self.piechart setDataSource:self];
    [self.piechart setStartPieAngle:M_PI_2];
    [self.piechart setAnimationSpeed:1.0];
    [self.piechart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:12]];
//    [self.piechart setLabelRadius:160];
    [self.piechart setShowPercentage:NO];
    [self.piechart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
//    [self.piechart setPieCenter:CGPointMake(240, 240)];
    [self.piechart setUserInteractionEnabled:NO];
    [self.piechart setLabelShadowColor:[UIColor blackColor]];
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
    [self setTodayTabBody:nil];
    [self setHistoryTabBody:nil];
    [self setPiechart:nil];
    [super viewDidUnload];
}
- (IBAction)selectTodayStat:(id)sender {
    self.todayTabBody.hidden = NO;
    self.historyTabBody.hidden = YES;
}

- (IBAction)selectHistoryStat:(id)sender {
    self.todayTabBody.hidden = YES;
    self.historyTabBody.hidden = NO;
}
#pragma mark - datasource
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

@end
