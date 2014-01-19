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
const static NSString *MAMapAPIKey = @"88c4c1b8e85d0d7d0fb45175636f2dfd";


#define DEVICE_SERVER_ADDR          @"http://61.190.30.170:8090"
#define GET_TIME_URL                [NSString stringWithFormat:@"%@%@", DEVICE_SERVER_ADDR, @"/rest/time"]
#define OPERATE_URL                 [NSString stringWithFormat:@"%@%@", DEVICE_SERVER_ADDR, @"/rest/operate"]

#define IMAGE_GET_ADDR              @"http://www.segopet.com/segoimg"
//#define SERVER_ADDR                 @"http://www.segopet.com/segopet"
#define SERVER_ADDR                 @"http://127.0.0.1:8080/segopet"


#define THIRD_LOGIN_URL             [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/thirdlogin"]
#define GET_PET_LIST_URL            [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/petinfo/getpets"]



