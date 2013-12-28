//
//  UserBean+Device.m
//  IPetChat
//
//  Created by king star on 13-12-22.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "UserBean+Device.h"

@implementation UserBean (Device)
- (void)setDevicePassword:(NSString *)devicePassword {
    if (devicePassword) {
        [self.extensionDic setObject:devicePassword forKey:@"DevicePassword"];
    }
}

- (NSString *)devicePassword {
    return [self.extensionDic objectForKey:@"DevicePassword"];
}

- (void)setPetInfo:(PetInfo *)petInfo {
    [self.extensionDic setObject:petInfo forKey:@"PetInfo"];
}

- (PetInfo *)petInfo {
    return [self.extensionDic objectForKey:@"PetInfo"];
}
@end
