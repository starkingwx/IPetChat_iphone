//
//  TestApiViewController.m
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "TestApiViewController.h"
#import "DeviceManager.h"
#import "CommonToolkit/CommonToolkit.h"
#import "PetInfoUtil.h"
#import "Constant.h"

@interface TestApiViewController ()

@end

@implementation TestApiViewController
@synthesize scrollView;
@synthesize motionCircleChart;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scrollView.contentSize = CGSizeMake(320, 800);
    [self.scrollView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSString *fakeData = @"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222222222222222222222222222222222222222222222200000000000055550000000000000000000011111100000000000000333333333333333333334444444444440000000000000002222222222222222222222333333333333330000000000000000000000";
    NSDictionary *motionDataDic = [PetInfoUtil parse288bitsMotionData:fakeData];
    NSArray *partStatArray = [motionDataDic objectForKey:KEY_PART_STAT];
    self.motionCircleChart.motionStatArray = partStatArray;
    self.motionCircleChart.descText = @"当前活跃指数:";
    self.motionCircleChart.point = 88;
    [self.motionCircleChart setNeedsDisplay];
    
    
    //
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
    self.barChart.dataArray = dataArray;
    [self.barChart setNeedsDisplay];
}

- (void)testQueryLatestPetInfo:(id)sender {
    [[DeviceManager shareDeviceManager] queryLastestInfoWithProcessor:self andFinishedRespSelector:@selector(onQueryFinished:) andFailedRespSelector:@selector(onQueryFail:)];
}

- (void)onQueryFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onQueryFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    NSString *responseText = [[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"response text: %@", responseText);
    
//    switch (statusCode) {
//            
//        case 200: {
//            // create group and invite ok
//            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
//            NSLog(@"response data: %@", jsonData);
//            if (jsonData) {
//                
//            } else {
//            }
//            
//            break;
//        }
//        default:
//            break;
//    }

}

- (void)onQueryFail:(ASIHTTPRequest *)pRequest {
    NSLog(@"onQueryFail - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
    NSLog(@"response data: %@", jsonData);
    
}

- (void)testQueryMotionStatInfo:(id)sender {
    NSDate *today = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
//    NSDateComponents *dateCom = [calender components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:today];
//    [dateCom setHour:0];
//    [dateCom setMinute:0];
//    [dateCom setSecond:0];
    NSDateComponents *dateDiff = [[NSDateComponents alloc] init];
    [dateDiff setDay:-6];
    NSDate *sevenDaysAgo = [calender dateByAddingComponents:dateDiff toDate:today options:0];
    
    
//    NSDate *beginTime = [calender dateFromComponents:dateCom];
    
    [[DeviceManager shareDeviceManager] queryPetExerciseStatInfoWithBeginTime:sevenDaysAgo andEndTime:today andProcessor:self andFinishedRespSelector:@selector(onFinishedQueryMotionStatInfo:) andFailedRespSelector:@selector(onQueryFail:)];
}

- (void)onFinishedQueryMotionStatInfo:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedQueryMotionStatInfo - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    
    NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
    NSLog(@"response data: %@", jsonData);
    
    switch (statusCode) {
            
        case 200: {
            // create group and invite ok
            if (jsonData) {
                NSString *status = [jsonData objectForKey:STATUS];
                if ([SUCCESS isEqualToString:status]) {
                    NSDictionary *archOp = [jsonData objectForKey:ArchOperation];
                    NSArray *dailySummaryArray = [archOp objectForKey:@"daily_summary"];
                    if (dailySummaryArray && [dailySummaryArray count] > 0) {
                        NSDictionary *today = [dailySummaryArray objectAtIndex:[dailySummaryArray count] - 1];
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
                        
                        NSInteger point = [PetInfoUtil calculateMotionPoint:vitality];
                        NSLog(@"point: %d", point);
                        
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

- (void)testOrderDeviceServer:(id)sender {
    [[DeviceManager shareDeviceManager] orderDeviceServerWithProcessor:self andFinishedRespSelector:@selector(onFinishedOrderDeviceServer:) andFailedRespSelector:@selector(onQueryFail:)];
}


- (void)onFinishedOrderDeviceServer:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedOrderDeviceServer - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
    NSLog(@"response data: %@", jsonData);
    
    switch (statusCode) {
            
        case 200: {
            // create group and invite ok
            if (jsonData) {
                
            } else {
            }
            
            break;
        }
        default:
            break;
    }
    
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setMotionCircleChart:nil];
    [self setBarChart:nil];
    [super viewDidUnload];
}
@end
