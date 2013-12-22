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

- (void)syncTime;

@end
