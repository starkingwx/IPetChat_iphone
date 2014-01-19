//
//  DeviceManager.m
//  IPetChat
//
//  Created by king star on 13-12-22.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "DeviceManager.h"
#import "UrlConfig.h"
#import "HttpUtils+DeviceServer.h"
#import "Operation.h"
#import "ArchiveOperation.h"
#import "Constant.h"
#import "PrintObject.h"
#import "WhereCond.h"
#import "TerminalControl.h"

static DeviceManager *instance;

@interface DeviceManager () {
    int _count;
    long long _timeDelta;
    long long _sysTimeBegin;
    NSTimer *_timer;
    
}

- (void)onGetTimeFinished:(ASIHTTPRequest *)pRequest;
- (void)postToDeviceServerWithOp:(Operation *)op andDeviceno:(NSString *)deviceno andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;
@end

@implementation DeviceManager

- (id)init {
    self = [super init];
    if (self) {
        _timeDelta = 0;
        _count = 0;
    }
    return self;
}

+ (DeviceManager *)shareDeviceManager{
    @synchronized(self){
        if (nil == instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

- (void)syncTime {
    NSLog(@"### time sync begin - count:%d ###", _count);
    _count++;

    _sysTimeBegin = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    [HttpUtils getRequestWithUrl:GET_TIME_URL andParameter:nil andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onGetTimeFinished:) andFailedRespSelector:@selector(onGEtTimeFailed:)];
}

- (void)onGEtTimeFailed:(ASIHTTPRequest *)pRequest {
    
}

- (void)onGetTimeFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onGetTimeFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            long long sysTimeReturn = (long long)([[NSDate date] timeIntervalSince1970] * 1000);

            int cost = (int)(sysTimeReturn - _sysTimeBegin);
            long long localSysTime = _sysTimeBegin + cost / 2;
            
            NSLog(@"systime begin: %lld, systime return: %lld, cost: %d", _sysTimeBegin, sysTimeReturn, cost);
            
            NSString *responseText = [[NSString alloc] initWithData:[pRequest responseData] encoding:NSUTF8StringEncoding];
            long long deviceSysTime = [responseText longLongValue];
            
            _timeDelta = deviceSysTime - localSysTime;
            NSLog(@"local systime: %lld, device server time: %lld,  delta: %lld", localSysTime, deviceSysTime, _timeDelta);
        }
    }
    NSLog(@"### time sync end ###");
}

- (void)startTimeSync {
    [self syncTime];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(syncTime) userInfo:nil repeats:YES];
}

- (void)stopTimeSync {
    [_timer invalidate];
}

- (void)postToDeviceServerWithOp:(Operation *)op andDeviceno:(NSString *)deviceno andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    
    NSData *jsonData = [PrintObject getJSON:op options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonOp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"postToDeviceServerWithOp: %@", jsonOp);
    
    
    long long currentTime = (long long)([[NSDate date] timeIntervalSince1970] * 1000) + _timeDelta;
    NSString *time = [NSString stringWithFormat:@"%lld", currentTime];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"MP", @"c", jsonOp, @"op", time, @"t", deviceno, @"d", @"1.0", @"v", nil];
    [HttpUtils postDeviceServerSignatureRequestWithUrl:OPERATE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFailRespSel];
}

- (void)queryLastestInfoWithProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    Operation *operation = [[Operation alloc] init];
    operation.cmdtype = ARCHIVE_OPERATION;
    
    ArchiveOperation *arop = [[ArchiveOperation alloc] init];
    arop.tablename = @"latestsdata";
    arop.operation = QUERY;
    
    operation.archive_operation = arop;
    
    NSArray *field = [NSArray arrayWithObjects:ID, TERMID, X, Y, POSID, SPEED, HEIGHT, DIRECTION, TERMTIME, SERVTIME, IOPORT, STATUS, ALARM, FENCE, FENCEID, MAINVOLTAGE, CELLVOLTAGE, TERMPERATURE, DISTANCE, VITALITY, ADDRESS, nil];
    
    arop.field = field;
    
    NSString *deviceno = @"10101010";
    [self postToDeviceServerWithOp:operation andDeviceno:deviceno andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFinRespSel];
}

- (void)queryPetExerciseStatInfoWithBeginTime:(NSDate *)beginTime andEndTime:(NSDate *)endTime andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    Operation *operation = [[Operation alloc] init];
    operation.cmdtype = ARCHIVE_OPERATION;

    ArchiveOperation *arop = [[ArchiveOperation alloc] init];
    arop.tablename = @"dailysummary";
    arop.operation = QUERY;

    operation.archive_operation = arop;
    
    NSArray *field = [NSArray arrayWithObjects:ID, TERMID, DAYTIME, TYPE, ALARM_SIZE, CRITIC_ALARM, DISTANCE0, DISTANCEN, VITALITY10, VITALITY1N, VITALITY20, VITALITY2N, VITALITY30, VITALITY3N, VITALITY40, VITALITY4N, nil];
    arop.field = field;
    
    WhereCond *wherecond1 = [[WhereCond alloc] init];
    wherecond1.name = @"begintime";
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *btime = [formater stringFromDate:beginTime];
    wherecond1.value = btime;
    
    WhereCond *wherecond2 = [[WhereCond alloc] init];
    wherecond2.name = @"endtime";
    wherecond2.value = [formater stringFromDate:endTime];
    
    arop.wherecond = [NSArray arrayWithObjects:wherecond1, wherecond2, nil];
        
    NSString *deviceno = @"10101010";
    [self postToDeviceServerWithOp:operation andDeviceno:deviceno andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFinRespSel];
}

- (void)orderDeviceServerWithProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    Operation *operation = [[Operation alloc] init];
    operation.cmdtype = TERMINAL_CONTROL;
    
    TerminalControl *termial = [[TerminalControl alloc] init];
    operation.terminal_control = termial;
    
    termial.cmdtype = ROLL_CALL;
    NSString *deviceno = @"10101010";
    termial.deviceno = deviceno;
    
    termial.roll_call = [[RollCall alloc] init];
    termial.roll_call.cycle = 10;
    termial.roll_call.duration = 60;
    
    [self postToDeviceServerWithOp:operation andDeviceno:deviceno andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFailRespSel];
    
}
@end
