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

static DeviceManager *instance;

@interface DeviceManager () {
    int _count;
    long long _timeDelta;
    long long _sysTimeBegin;
    NSTimer *_timer;
    
}

- (void)onGetTimeFinished:(ASIHTTPRequest *)pRequest;

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
    _sysTimeBegin = (long long)([[NSData data] timeIntervalSince1970] * 1000);
    [HttpUtils getRequestWithUrl:GET_TIME_URL andParameter:nil andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onGetTimeFinished:) andFailedRespSelector:nil];
}

- (void)onGetTimeFinished:(ASIHTTPRequest *)pRequest {
    NSLog(@"onGetTimeFinished - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            long long sysTimeReturn = (long long)([[NSData data] timeIntervalSince1970] * 1000);

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
    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(syncTime) userInfo:nil repeats:YES];
}

- (void)stopTimeSync {
    [_timer invalidate];
}

@end
