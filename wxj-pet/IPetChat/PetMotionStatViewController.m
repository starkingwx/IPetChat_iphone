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
#import "MotionStat.h"

static const int TOTAL_HISTORY_DAYS = 7;

@interface PetMotionStatViewController () {
    AsynImageView *_avatarView;
    NSArray *_bcTitleArray;
    NSArray *_bcValueArray;
    NSArray *_bcColorArray;
    NSArray *_bcLabelColorArray;
    NSDateFormatter *_historyDateFormatter;
    NSDateFormatter *_displayDateFormatter;
    NSCalendar *_calendar;
}

@end

@implementation PetMotionStatViewController

@synthesize avatarImageViewContainer;
@synthesize nicknameLabel;
@synthesize breedLabel;
@synthesize ageLabel;
@synthesize heightLabel;
@synthesize weightLabel;
@synthesize todayTabBody;
@synthesize historyTabBody;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Motion And Health", @"运动健康");
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Motion And Health", @"") image:[UIImage imageNamed:@"ic_motion"] tag:1];

        _bcColorArray = [NSArray arrayWithObjects:BLUE_VALUE, GREEN_VALUE, BLUE_VALUE, GREEN_VALUE, BLUE_VALUE, GREEN_VALUE, BLUE_VALUE, nil];
        _bcLabelColorArray = [NSArray arrayWithObjects:BLUE_VALUE, WHITE_VALUE, BLUE_VALUE, WHITE_VALUE, BLUE_VALUE, WHITE_VALUE, BLUE_VALUE, nil];

        _bcTitleArray = [NSArray arrayWithObjects:@" ", @" ", @" ", @" ", @" ", @" ", @" ", nil];
        _bcValueArray = [NSArray arrayWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", @"0", nil];
        
        _historyDateFormatter = [[NSDateFormatter alloc] init];
        [_historyDateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSTimeZone *timezone = [NSTimeZone timeZoneForSecondsFromGMT:8];
        [_historyDateFormatter setTimeZone:timezone];
        
        _displayDateFormatter = [[NSDateFormatter alloc] init];
        [_displayDateFormatter setDateFormat:@"MM-dd"];
        [_displayDateFormatter setTimeZone:timezone];
        
        _calendar = [NSCalendar currentCalendar];
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
    
//    
//    // test
    NSString *fakeData = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222200000000000055550000000000000000000011111100000000000000333333333333333333334444444444440000000000000002222222222222222222222333333333333330000000000000000000000";
    NSDictionary *motionDataDic = [PetInfoUtil parse288bitsMotionData:fakeData];
    [self fillTodayInfo:motionDataDic];
    
    
    NSDictionary *totalDic = [motionDataDic objectForKey:KEY_TOTAL_STAT];
    NSMutableDictionary *firstDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [firstDayDic setObject:@"4月20日" forKey:KEY_DAY];
    NSMutableDictionary *secondDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [secondDayDic setObject:@"4月21日" forKey:KEY_DAY];
    NSMutableDictionary *thirdDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [thirdDayDic setObject:@"4月22日" forKey:KEY_DAY];
    NSMutableDictionary *fourthDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [fourthDayDic setObject:@"4月23日" forKey:KEY_DAY];
    NSMutableDictionary *fifthDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [fifthDayDic setObject:@"4月24日" forKey:KEY_DAY];
    NSMutableDictionary *sixthDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [sixthDayDic setObject:@"4月25日" forKey:KEY_DAY];
    NSMutableDictionary *seventhDayDic = [NSMutableDictionary dictionaryWithDictionary:totalDic];
    [seventhDayDic setObject:@"4月26日" forKey:KEY_DAY];
    
    NSArray *dataArray = [NSArray arrayWithObjects:firstDayDic, secondDayDic, thirdDayDic, fourthDayDic, fifthDayDic, sixthDayDic, seventhDayDic, nil];
    [self renderHistoryData:dataArray];
}

- (void)viewDidAppear:(BOOL)animated {
   
}

- (void)queryPetInfo {
//    UserBean *user = [[UserManager shareUserManager] userBean];
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
            NSString *birthdayText = [NSString stringWithFormat:@"%@个月", month];
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
   
    [self setTodayTabBody:nil];
    [self setHistoryTabBody:nil];
    [_avatarView removeFromSuperview];
    [self setPlayTimeLabel:nil];
    [self setRunningTimeLabel:nil];
    [self setWalkTimeLabel:nil];
    [self setRestTimeLabel:nil];
    [self setClockChart:nil];
    [self setLineBarChart:nil];
    [super viewDidUnload];
}
- (IBAction)selectTodayStat:(id)sender {
    self.todayTabBody.hidden = NO;
    self.historyTabBody.hidden = YES;

    
    // test
//    NSString *fakeData = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222200000000000055550000000000000000000011111100000000000000333333333333333333334444444444440000000000000002222222222222222222222333333333333330000000000000000000000";
//    NSDictionary *motionDataDic = [PetInfoUtil parse288bitsMotionData:fakeData];
//    [self fillTodayInfo:motionDataDic];

}

- (IBAction)selectHistoryStat:(id)sender {
    self.todayTabBody.hidden = YES;
    self.historyTabBody.hidden = NO;
    
    [self queryHistoryMotionStatInfo];
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
                        [self fillTodayInfo:data];
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


- (void)fillTodayInfo:(NSDictionary *)data {
    // set motion point progress
//    NSNumber *vita = [data objectForKey:VITALITY];
//    long vitality = [vita longValue];
//    float motionPercentage = [PetInfoUtil calculateAvgMotionPercentage:vitality];
//    NSInteger point = [PetInfoUtil calculateMotionPoint:vitality];
//    
//    // init pie chart data
//    int rest = [PetInfoUtil parsePetRestPercentage:vitality] * 100;
//    int walk = [PetInfoUtil parsePetWalkPercentage:vitality] * 100;
//    int runSlightly = [PetInfoUtil parsePetRunSlightlyPercentage:vitality] * 100;
//    int runHeavily = [PetInfoUtil parsePetRunHeavilyPercentage:vitality] * 100;
    
    NSArray *partStatArray = [data objectForKey:KEY_PART_STAT];
    self.clockChart.motionStatArray = partStatArray;
    self.clockChart.descText = @"当前活跃指数:";
    self.clockChart.point = 88;
    [self.clockChart setNeedsDisplay];
    
    NSDictionary *totalDic = [data objectForKey:KEY_TOTAL_STAT];
    MotionStat *rest = [totalDic objectForKey:KEY_REST];
    MotionStat *walk = [totalDic objectForKey:KEY_WALK];
    MotionStat *play = [totalDic objectForKey:KEY_PLAY];
    MotionStat *running = [totalDic objectForKey:KEY_RUNNING];
    
    self.restTimeLabel.text = [PetInfoUtil generateTimeStringFromMotionStat:rest];
    self.walkTimeLabel.text = [PetInfoUtil generateTimeStringFromMotionStat:walk];
    self.playTimeLabel.text = [PetInfoUtil generateTimeStringFromMotionStat:play];
    self.runningTimeLabel.text = [PetInfoUtil generateTimeStringFromMotionStat:running];

}

- (void)queryHistoryMotionStatInfo {
    NSDate *today = [NSDate date];
    //    NSDateComponents *dateCom = [_calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:today];
    //    [dateCom setHour:0];
    //    [dateCom setMinute:0];
    //    [dateCom setSecond:0];
    NSDateComponents *dateDiff = [[NSDateComponents alloc] init];
    [dateDiff setDay:-6];
    NSDate *sevenDaysAgo = [_calendar dateByAddingComponents:dateDiff toDate:today options:0];

    //    NSDate *beginTime = [_calendar dateFromComponents:dateCom];
    
    [[DeviceManager shareDeviceManager] queryPetExerciseStatInfoWithBeginTime:sevenDaysAgo andEndTime:today andProcessor:self andFinishedRespSelector:@selector(onFinishedQueryMotionStatInfo:) andFailedRespSelector:nil];
}

- (void)onFinishedQueryMotionStatInfo:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedQueryMotionStatInfo - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
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
                    NSArray *dailySummaryArray = [archOp objectForKey:@"daily_summary"];
                    [self fillHistoryData:dailySummaryArray];
                }
                
                
            } else {
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)fillHistoryData:(NSArray*)dailySummary {
    if (dailySummary && [dailySummary count] > 0) {
        NSDictionary *today = [dailySummary objectAtIndex:[dailySummary count] - 1];
        NSNumber *vitality20 = [today objectForKey:VITALITY20];
        NSNumber *vitality2N = [today objectForKey:VITALITY2N];
        NSNumber *vitality30 = [today objectForKey:VITALITY30];
        NSNumber *vitality3N = [today objectForKey:VITALITY3N];
        NSNumber *vitality40 = [today objectForKey:VITALITY40];
        NSNumber *vitality4N = [today objectForKey:VITALITY4N];
        
        unsigned long walkTime = [vitality2N unsignedLongValue] - [vitality20 unsignedLongValue];
        unsigned long runSlightlyTime = [vitality3N unsignedLongValue] - [vitality30 unsignedLongValue];
        unsigned long runHeavilyTime = [vitality4N unsignedLongValue] - [vitality40 unsignedLongValue];
        
        unsigned long vitality = [PetInfoUtil calculate4MotionPartPercentageByWalkTime:walkTime andRunSlightlyTime:runSlightlyTime andRunHeavily:runHeavilyTime];
        
        NSInteger todayPoint = [PetInfoUtil calculateMotionPoint:vitality];
        NSLog(@"point: %d", todayPoint);
        
        NSMutableArray *historyPoints = [[NSMutableArray alloc] initWithCapacity:6];
        NSMutableArray *historyDates = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i = 0; i < [dailySummary count] - 1; i++) {
            NSDictionary *day = [dailySummary objectAtIndex:i];
            NSDictionary *dayNext = [dailySummary objectAtIndex:i + 1];
            
            NSNumber *vitality20Day = [day objectForKey:VITALITY20];
            NSNumber *vitality30Day = [day objectForKey:VITALITY30];
            NSNumber *vitality40Day = [day objectForKey:VITALITY40];
            
            NSNumber *vitality20DayNext = [dayNext objectForKey:VITALITY20];
            NSNumber *vitality30DayNext = [dayNext objectForKey:VITALITY30];
            NSNumber *vitality40DayNext = [dayNext objectForKey:VITALITY40];
            
            walkTime = [vitality20DayNext unsignedLongValue] - [vitality20Day unsignedLongValue];
            runSlightlyTime = [vitality30DayNext unsignedLongValue] - [vitality30Day unsignedLongValue];
            runHeavilyTime = [vitality40DayNext unsignedLongValue] - [vitality40Day unsignedLongValue];
            
            vitality = [PetInfoUtil calculate4MotionPartPercentageByWalkTime:walkTime andRunSlightlyTime:runSlightlyTime andRunHeavily:runHeavilyTime];
            NSInteger point = [PetInfoUtil calculateMotionPoint:vitality];
            [historyPoints addObject:[NSNumber numberWithInteger:point]];
            
            [historyDates addObject:[day objectForKey:DAYTIME]];
        }
        
        [historyPoints addObject:[NSNumber numberWithInteger:todayPoint]];
        [historyDates addObject:[today objectForKey:DAYTIME]];
        
        NSLog(@"history dates: %@", historyDates);
        
        int dayGap = TOTAL_HISTORY_DAYS - [historyPoints count];
        if (dayGap > 0) {
            // calcualte the date that is not returned 
            NSString *firstDayTime = [historyDates objectAtIndex:0];
            NSDate *firstDate = [_historyDateFormatter dateFromString:firstDayTime];
            NSLog(@"firstDayTime : %@, first date: %@", firstDayTime, firstDate);
            
            for (int i = 0; i < dayGap; i++) {
                NSDateComponents *dateDiff = [[NSDateComponents alloc] init];
                [dateDiff setDay:i - dayGap];
                NSDate *historyDay = [_calendar dateByAddingComponents:dateDiff toDate:firstDate options:0];
                [historyDates insertObject:[_historyDateFormatter stringFromDate:historyDay] atIndex:i];
                [historyPoints insertObject:[NSNumber numberWithInt:0] atIndex:i];
            }
        }
        
        NSMutableArray *titleArray = [[NSMutableArray alloc] initWithCapacity:historyDates.count];
        NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:historyPoints.count];
        for (int i = 0; i < [historyDates count]; i++) {
            [valueArray addObject:[[historyPoints objectAtIndex:i] stringValue]];
            
            NSString *dateTime = [historyDates objectAtIndex:i];
            NSDate *date = [_historyDateFormatter dateFromString:dateTime];
            [titleArray addObject:[_displayDateFormatter stringFromDate:date]];
        }
        
     
    }

}

- (void)renderHistoryData:(NSArray *)dataArray {
    self.lineBarChart.dataArray = dataArray;
    [self.lineBarChart setNeedsDisplay];

}

@end
