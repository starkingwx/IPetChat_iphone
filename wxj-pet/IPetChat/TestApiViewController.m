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
    
    self.scrollView.contentSize = CGSizeMake(320, 600);
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
    [self.motionCircleChart setNeedsDisplay];
}

- (void)testQueryLatestPetInfo:(id)sender {
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
                
            } else {
            }
            
            break;
        }
        default:
            break;
    }

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
    [[DeviceManager shareDeviceManager] orderDeviceServerWithProcessor:self andFinishedRespSelector:@selector(onFinishedOrderDeviceServer:) andFailedRespSelector:nil];
}


- (void)onFinishedOrderDeviceServer:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedOrderDeviceServer - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
            
        case 200: {
            // create group and invite ok
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"response data: %@", jsonData);
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
    [super viewDidUnload];
}
@end
