//
//  UrlConfig.h
//  IPetChat
//
//  Created by king star on 13-12-14.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppKey         @"3809471856"
#define kRedirectURI    @"https://api.weibo.com/oauth2/default.html"
#define TencentAppId    @"100585565"

#define DEVICE_SERVER_ADDR          @"http://61.190.30.170:8090"
#define GET_TIME_URL                [NSString stringWithFormat:@"%@%@", DEVICE_SERVER_ADDR, @"/rest/time"]
#define OPERATE_URL                 [NSString stringWithFormat:@"%@%@", DEVICE_SERVER_ADDR, @"/rest/operate"]


#define SERVER_ADDR                 @"http://www.segopet.com/segopet"
#define THIRD_LOGIN_URL             [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/thirdlogin"]



