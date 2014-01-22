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
#import "DeviceManager.h"

@interface PetMotionStatViewController () {
    AsynImageView *_avatarView;
    NSArray *_bcTitleArray;
    NSArray *_bcValueArray;
    NSArray *_bcColorArray;
    NSArray *_bcLabelColorArray;
    NSArray *_barChartDataArray;
}
@property (nonatomic) NSMutableArray *slices;
@property (nonatomic) NSArray *sliceColors;

@end

@implementation PetMotionStatViewController

@synthesize avatarImageViewContainer;
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
@synthesize barChart;
@synthesize scoreLabel;
@synthesize scoreProgressView;
@synthesize restPercentLabel;
@synthesize walkPercentLabel;
@synthesize runSlightlyPercentLabel;
@synthesize runHeavilyPercentLabel;
@synthesize totalTimeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Motion And Health", @"运动健康");
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Motion And Health", @"") image:[UIImage imageNamed:@"ic_motion"] tag:1];

        self.sliceColors = [NSArray arrayWithObjects:BLUE,
                            GREEN,
                            YELLOW,
                            ORANGE
                            ,nil];
        
        self.slices = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
        
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UserBean *user = [[UserManager shareUserManager] userBean];
    PetInfo *petInfo = user.petInfo;
    [self fillPetInfo:petInfo];
    
    [self queryLatestPetDeviceInfo];
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

- (void)fillPetInfo:(PetInfo *)petInfo {
    if (petInfo && petInfo.petId) {
        [_avatarView setImageURL:[NSString stringWithFormat:@"%@/%@", IMAGE_GET_ADDR, petInfo.avatar]];
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

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.todayTabBody.hidden = NO;
    self.historyTabBody.hidden = YES;
    
    CGRect frame = self.avatarImageViewContainer.frame;
    _avatarView = [[AsynImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.avatarImageViewContainer addSubview:_avatarView];
    [_avatarView setPlaceholderImage:[UIImage imageNamed:@"img_petstar"]];
    
    // pie chart
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
    
    
    // bar chart
    //Set the Shape of the Bars (Rounded or Squared) - Rounded is default
    [self.barChart setupBarViewShape:BarShapeSquared];
    
    //Set the Style of the Bars (Glossy, Matte, or Flat) - Glossy is default
    [self.barChart setupBarViewStyle:BarStyleFlat];
    
    //Set the Drop Shadow of the Bars (Light, Heavy, or None) - Light is default
    [self.barChart setupBarViewShadow:BarShadowNone];
    
    _bcTitleArray = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", nil];
    _bcValueArray = [NSArray arrayWithObjects:@"10", @"0", @"10", @"22", @"34", @"50", nil];
    _bcColorArray = [NSArray arrayWithObjects:BLUE_VALUE, BLUE_VALUE, GREEN_VALUE, YELLOW_VALUE, ORANGE_VALUE, GREEN_VALUE, nil];
    _bcLabelColorArray = [NSArray arrayWithObjects:@"FFFFFF",@"FFFFFF",@"FFFFFF", @"FFFFFF", @"FFFFFF", @"FFFFFF", nil];
    _barChartDataArray = [barChart createChartDataWithTitles:_bcTitleArray values:_bcValueArray colors:_bcColorArray labelColors:_bcLabelColorArray];

    
    //Generate the bar chart using the formatted data
    [self.barChart setDataWithArray:_barChartDataArray
                      showAxis:DisplayOnlyYAxis
                     withColor:[UIColor whiteColor]
       shouldPlotVerticalLines:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAvatarImageViewContainer:nil];
    [self setNicknameLabel:nil];
    [self setBreedLabel:nil];
    [self setAgeLabel:nil];
    [self setHeightLabel:nil];
    [self setWeightLabel:nil];
    [self setUsageCountLabel:nil];
    [self setTodayTabBody:nil];
    [self setHistoryTabBody:nil];
    [self setPiechart:nil];
    [_avatarView removeFromSuperview];
    [self setBarChart:nil];
    [self setScoreProgressView:nil];
    [self setScoreLabel:nil];
    [self setRestPercentLabel:nil];
    [self setWalkPercentLabel:nil];
    [self setRunSlightlyPercentLabel:nil];
    [self setRunHeavilyPercentLabel:nil];
    [self setTotalTimeLabel:nil];
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
    // set motion point progress
    NSNumber *vita = [data objectForKey:VITALITY];
    long vitality = [vita longValue];
    float motionPercentage = [PetInfoUtil calculateAvgMotionPercentage:vitality];
    NSInteger point = [PetInfoUtil calculateMotionPoint:vitality];
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", point];
    [self.scoreProgressView setProgress:motionPercentage animated:YES];
    
    // init pie chart data
    int rest = [PetInfoUtil parsePetRestPercentage:vitality] * 100;
    int walk = [PetInfoUtil parsePetWalkPercentage:vitality] * 100;
    int runSlightly = [PetInfoUtil parsePetRunSlightlyPercentage:vitality] * 100;
    int runHeavily = [PetInfoUtil parsePetRunHeavilyPercentage:vitality] * 100;
    self.slices = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:rest], [NSNumber numberWithInt:walk], [NSNumber numberWithInt:runSlightly], [NSNumber numberWithInt:runHeavily], nil];
    [self.piechart reloadData];
    
    self.restPercentLabel.text = [NSString stringWithFormat:@"%d%%", rest];
    self.walkPercentLabel.text = [NSString stringWithFormat:@"%d%%", walk];
    self.runSlightlyPercentLabel.text = [NSString stringWithFormat:@"%d%%", runSlightly];
    self.runHeavilyPercentLabel.text = [NSString stringWithFormat:@"%d%%", runHeavily];


}

@end
