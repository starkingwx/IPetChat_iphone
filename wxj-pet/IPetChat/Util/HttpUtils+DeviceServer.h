//
//  HttpUtils+DeviceServer.h
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import <CommonToolkit/CommonToolkit.h>

@interface HttpUtils (DeviceServer)

// get signature http request
+ (void)getDeviceServerSignatureRequestWithUrl:(NSString *)pUrl andParameter:(NSDictionary *)pParameter andUserInfo:(NSDictionary *)pUserInfo andRequestType:(HTTPRequestType)pType andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;

// post signature http request
+ (void)postDeviceServerSignatureRequestWithUrl:(NSString *)pUrl andPostFormat:(HttpPostFormat)pPostFormat andParameter:(NSMutableDictionary *)pParameter andUserInfo:(NSDictionary *)pUserInfo andRequestType:(HTTPRequestType)pType andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel;

@end
