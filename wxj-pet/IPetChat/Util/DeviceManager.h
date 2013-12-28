//
//  DeviceManager.h
//  IPetChat
//
//  Created by king star on 13-12-22.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject
+ (DeviceManager *)shareDeviceManager;

- (void)queryLastestInfoWithProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;

- (void)queryPetExerciseStatInfoWithBeginTime:(NSDate *)beginTime andEndTime:(NSDate *)endTime andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;

- (void)orderDeviceServerWithProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;

- (void)syncTime;
- (void)startTimeSync;
- (void)stopTimeSync;
@end
