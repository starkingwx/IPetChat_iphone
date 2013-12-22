//
//  HttpUtils+DeviceServer.m
//  IPetChat
//
//  Created by king star on 13-12-21.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "HttpUtils+DeviceServer.h"
#import "UserBean+Device.h"

#define SIGNATURE_PARAMETER_KEY    @"s"

@implementation HttpUtils (DeviceServer)

// generate signature with request parameter
+ (NSString *)generateSignatureWithParameter:(NSDictionary *)pParameter andCipherKey:(NSString *)cipherKey {
    if (pParameter == nil || [pParameter count] == 0 || cipherKey == nil) {
        return @"";
    }
    
    // create need to signature parameter data array
    NSMutableArray *_parameterDataArray = [[NSMutableArray alloc] init];
    
    // init need to signature parameter data array
    [pParameter enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [_parameterDataArray addObject:[NSString stringWithFormat:@"%@%@", key, obj]];
    }];
    
    NSLog(@"post body data array = %@", _parameterDataArray);
    
    // sort parameter data array
    NSMutableArray *_sortedParameterDataArray = [[NSMutableArray alloc] initWithArray:[_parameterDataArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    NSLog(@"sorted post body data array = %@", _sortedParameterDataArray);
    
    // append userKey to sort parameter data array
    if([[[UserManager shareUserManager] userBean] userKey]){
        [_sortedParameterDataArray addObject:[[[UserManager shareUserManager] userBean] userKey]];
    }
    
    // add cipher key

    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    [paramArray addObject:cipherKey];
    [paramArray addObjectsFromArray:_sortedParameterDataArray];
    [paramArray addObject:cipherKey];
    
    NSLog(@"after append cipher, sorted post body data array = %@", paramArray);
    
    // generate signature
    NSString *_signature = [[paramArray toStringWithSeparator:nil] md5];
    NSLog(@"the signature is %@", _signature);
    
    return _signature;
}


+ (void)getDeviceServerSignatureRequestWithUrl:(NSString *)pUrl andParameter:(NSDictionary *)pParameter andUserInfo:(NSDictionary *)pUserInfo andRequestType:(HTTPRequestType)pType andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    // create and init signature get request parameter
    NSMutableDictionary *_signatureGetRequestParameter = [NSMutableDictionary dictionaryWithDictionary:pParameter];
    
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    
    // add signature to get request url
    [_signatureGetRequestParameter setObject:[self generateSignatureWithParameter:pParameter andCipherKey:[[userBean devicePassword] md5]] forKey:SIGNATURE_PARAMETER_KEY];
    
    // send get request
    [self getRequestWithUrl:pUrl andParameter:_signatureGetRequestParameter andUserInfo:pUserInfo andRequestType:pType andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFailRespSel];
}


+ (void)postDeviceServerSignatureRequestWithUrl:(NSString *)pUrl andPostFormat:(HttpPostFormat)pPostFormat andParameter:(NSMutableDictionary *)pParameter andUserInfo:(NSDictionary *)pUserInfo andRequestType:(HTTPRequestType)pType andProcessor:(id)pProcessor andFinishedRespSelector:(SEL)pFinRespSel andFailedRespSelector:(SEL)pFailRespSel {
    // check parameter
    pParameter = pParameter ? pParameter : [[NSMutableDictionary alloc] init];
    
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    
    // add signature to post parameter
    [pParameter setObject:[self generateSignatureWithParameter:pParameter andCipherKey:[[userBean devicePassword] md5]] forKey:SIGNATURE_PARAMETER_KEY];
    
    // send post request
    [self postRequestWithUrl:pUrl andPostFormat:pPostFormat andParameter:pParameter andUserInfo:pUserInfo andRequestType:pType andProcessor:pProcessor andFinishedRespSelector:pFinRespSel andFailedRespSelector:pFailRespSel];
}

@end
