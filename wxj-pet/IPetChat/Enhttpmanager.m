//
//  Enhttpmanager.m
//  IPetChat
//
//  Created by WXJ on 13-11-11.
//  Copyright (c) 2013年 XF. All rights reserved.
//

#import "Enhttpmanager.h"
#import "CommonToolkit/CommonToolkit.h"
#import "UserBean+Device.h"
#import "UrlConfig.h"

#define BOUNDARY @"------------0x0x0x0x0x0x0x0x"

typedef enum {
    PORTAL_STAGE_TEST_CONNECTION,
    PORTAL_STAGE_GET_PETLIST,
    PORTAL_STAGE_LOGIN,
    PORTAL_STAGE_LOGOUT,
    PORTAL_STAGE_MODIFY_PETINFO,
    PORTAL_STAGE_GET_RECOMMENDPETS,
    PORTAL_STAGE_GET_NEARBYPETS,
    PORTAL_STAGE_GET_CONCERNPETS,
    PORTAL_STAGE_CONCERN_PETS,
    PORTAL_STAGE_UNCONCERN_PETS,
    PORTAL_STAGE_LEAVE_MSG,
    PORTAL_STAGE_GET_LEAVEMSG,
    PORTAL_STAGE_REPLY_MSG,
    PORTAL_STAGE_DEL_MSG,
    PORTAL_STAGE_GET_LEAVEMSG_DETAIL,
    PORTAL_STAGE_GET_BLACKLIST,
    PORTAL_STAGE_ADD_BLACKLIST,
    PORTAL_STAGE_DEL_BLACKLIST,
    PORTAL_STAGE_SEARCH_PETS,
    PORTAL_STAGE_GET_PETDETAIL,
    PORTAL_STAGE_UPLOAD_IMAGE,
    PORTAL_STAGE_MODIFY_PWD,
    PORTAL_STAGE_GET_GALLERYLIST,
    PORTAL_STAGE_GET_GALLERY,
    PORTAL_STAGE_UPLOAD_GALLERYIMAGE,
    PORTAL_STAGE_CREATE_GALLERY,
    PORTAL_STAGE_MODIFY_GALLERYINFO,
    PORTAL_STAGE_DELETE_PHOTO,
    PORTAL_STAGE_DELETE_GALLERY
} PORTAL_STAGE;

typedef enum {
    PORTAL_COMMAND_NONE,
    PORTAL_COMMAND_CHECK,
    PORTAL_COMMAND_GET_PETLIST,
    PORTAL_COMMAND_LOGIN,
    PORTAL_COMMAND_LOGOUT,
    PORTAL_COMMAND_MODIFY_PETINFO,
    PORTAL_COMMAND_GET_RECOMMENDPETS,
    PORTAL_COMMAND_GET_NEARBYPETS,
    PORTAL_COMMAND_GET_CONCERNPETS,
    PORTAL_COMMAND_CONCERN_PETS,
    PORTAL_COMMAND_UNCONCERN_PETS,
    PORTAL_COMMAND_LEAVE_MSG,
    PORTAL_COMMAND_GET_LEAVEMSG,
    PORTAL_COMMAND_REPLY_MSG,
    PORTAL_COMMAND_DEL_MSG,
    PORTAL_COMMAND_GET_LEAVEMSG_DETAIL,
    PORTAL_COMMAND_GET_BLACKLIST,
    PORTAL_COMMAND_ADD_BLACKLIST,
    PORTAL_COMMAND_DEL_BLACKLIST,
    PORTAL_COMMAND_SEARCH_PETS,
    PORTAL_COMMAND_GET_PETDETAIL,
    PORTAL_COMMAND_UPLOAD_IMAGE,
    PORTAL_COMMAND_MODIFY_PWD,
    PORTAL_COMMAND_GET_GALLERYLIST,
    PORTAL_COMMAND_GET_GALLERY,
    PORTAL_COMMAND_UPLOAD_GALLERYIMAGE,
    PORTAL_COMMAND_CREATE_GALLERY,
    PORTAL_COMMAND_MODIFY_GALLERYINFO,
    PORTAL_COMMAND_DELETE_PHOTO,
    PORTAL_COMMAND_DELETE_GALLERY
} PORTAL_COMMAND;

@implementation Enhttpmanager{
    NSMutableData   *responseData;
    PORTAL_STAGE    stage;
    PORTAL_COMMAND  current_command;
    id              portal_result_callback_object;
    SEL             portal_result_callback_selector;
    NSURLConnection *connection;
    BOOL            connection_init;
    NSTimer         *timeout_timer;
    NSObject        *returnData;
    NSString        *filename;
}

+ (Enhttpmanager*)sharedSingleton
{
    static Enhttpmanager *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[Enhttpmanager alloc] init];
        return sharedSingleton;
    }
}

- (id)init
{
    self = [super init];
    current_command = PORTAL_COMMAND_NONE;
    returnData = nil;
    connection = [[NSURLConnection alloc] init];
    connection_init = NO;
    responseData = [[NSMutableData data] retain];
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

//发送HTTP请求，网络侧返回的错误类型
- (void)portalResult:(PORTAL_RESULT)result error:(PORTAL_ERROR)error {
    if (timeout_timer && [timeout_timer isValid]) {
        [timeout_timer invalidate];
        timeout_timer = nil;
    }
    
    [portal_result_callback_object performSelector:portal_result_callback_selector withObject:[NSArray arrayWithObjects: [NSNumber numberWithInt:result], [NSNumber numberWithInt:error], returnData, nil]];
    current_command = PORTAL_COMMAND_NONE;
}

//http get 请求（用来ping baidu 看网络是否通畅）
- (void)sendGetRequest:(NSString*)url {
    if (![url hasPrefix:@"http://"]) {
        url = [NSString stringWithFormat:@"%@%@", SERVER_ADDR, url];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setValue:@"G3WLAN" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [connection initWithRequest:request delegate:self];
        connection_init = YES;
    });
}

//http post 请求
- (void)sendPostRequest:(NSString*)url body:(NSData*)body {
    if (![url hasPrefix:@"http://"]) {
        url = [NSString stringWithFormat:@"%@%@", SERVER_ADDR, url];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    if (stage == PORTAL_STAGE_UPLOAD_IMAGE||stage == PORTAL_STAGE_UPLOAD_GALLERYIMAGE) {
        NSString* MultiPartContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
        [request setValue:MultiPartContentType forHTTPHeaderField: @"Content-Type"];
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    }
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    dispatch_async(dispatch_get_main_queue(), ^{
        [connection initWithRequest:request delegate:self];
        connection_init = YES;
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
}

//URL重定向
- (NSURLRequest *)connection:(NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse;
{
    return inRequest;
}

//HTTP请求成功，并返回了相对应结果
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *htmlString;
    if (stage == PORTAL_STAGE_TEST_CONNECTION) {
        htmlString = [[NSString alloc] initWithData:responseData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    } else {
        htmlString = [[NSString alloc] initWithData:responseData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    }
    if (htmlString == nil && stage == PORTAL_STAGE_TEST_CONNECTION) {
        htmlString = [[NSString alloc] initWithData:responseData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    }
    
    PORTAL_RESULT result = PORTAL_RESULT_FAILED;
    PORTAL_ERROR error = PORTAL_ERROR_HTML;
    if (htmlString == nil) {
        [htmlString release];
        [self portalResult:result error:error];
        return;
    }
    //检测网络状态
    if (stage == PORTAL_STAGE_TEST_CONNECTION) {
        NSRange range = [htmlString rangeOfString:@"news.baidu.com" options:0];
        if(range.location != NSNotFound) {
            result = PORTAL_RESULT_ALREADY;
            error = PORTAL_ERROR_OK;
        }
    }else if (stage == PORTAL_STAGE_LOGIN){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[petinfodic objectForKey:@"userkey"] forKey:@"userkey"];
        [defaults setObject:[petinfodic objectForKey:@"username"] forKey:@"username"];
        [defaults setObject:[petinfodic objectForKey:@"userId"] forKey:@"userid"];
        [defaults setObject:[petinfodic objectForKey:@"result"] forKey:@"loginresult"];
        [defaults synchronize];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_LOGIN_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_PETLIST){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        //int ret = [[petinfodic objectForKey:@"result"] intValue];
        NSArray *array = [petinfodic objectForKey:@"list"];
        NSDictionary *petdict = [array objectAtIndex:0];
        returnData = [[NSDictionary alloc]initWithDictionary:petdict];
        result = PORTAL_RESULT_GET_PETLIST_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_PETDETAIL){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_PETDETAIL_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_SEARCH_PETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_SEARCH_PETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_MODIFY_PETINFO){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_MODIFY_PETINFO_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_RECOMMENDPETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_RECOMMENDPETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_NEARBYPETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_NEARBYPETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_CONCERNPETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_CONCERNPETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_CONCERN_PETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_CONCERN_PETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_UNCONCERN_PETS){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_UNCONCERN_PETS_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_LEAVE_MSG){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_LEAVE_MSG_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_LEAVEMSG){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_LEAVEMSG_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_REPLY_MSG){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_REPLY_MSG_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_DEL_MSG){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_DEL_MSG_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_LEAVEMSG_DETAIL){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_LEAVEMSG_DETAIL_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_BLACKLIST){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_BLACKLIST_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_ADD_BLACKLIST){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_ADD_BLACKLIST_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_DEL_BLACKLIST){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_DEL_BLACKLIST_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_UPLOAD_IMAGE){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_UPLOAD_IMAGE_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_MODIFY_PWD){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_MODIFY_PWD_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_GALLERYLIST){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_GALLERYLIST_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_GET_GALLERY){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_GET_GALLERY_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_UPLOAD_GALLERYIMAGE){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_UPLOAD_GALLERYIMAGE_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_CREATE_GALLERY){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_CREATE_GALLERY_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_MODIFY_GALLERYINFO){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_MODIFY_GALLERYINFO_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_DELETE_PHOTO){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_DELETE_PHOTO_SUCCESS;
        error = PORTAL_ERROR_OK;
    }else if (stage == PORTAL_STAGE_DELETE_GALLERY){
        NSDictionary *petinfodic = [NSJSONSerialization JSONObjectWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        returnData = [[NSDictionary alloc]initWithDictionary:petinfodic];
        result = PORTAL_RESULT_DELETE_GALLERY_SUCCESS;
        error = PORTAL_ERROR_OK;
    }
    NSLog(@"htmlstring is %@",htmlString);
    [htmlString release];
    [self portalResult:result error:error];
}

//检测网络状态
- (void)checkOnlineStatus:(id)callback_object selector:(SEL)callback_selector
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_CHECK;
    stage = PORTAL_STAGE_TEST_CONNECTION;
    [self sendGetRequest:@"http://www.baidu.com/"];
}

//取消HTTP请求
- (void)cancelHttpConnection
{
    if (timeout_timer && [timeout_timer isValid]) {
        [timeout_timer invalidate];
        timeout_timer = nil;
    }
    if (connection_init) {
        [connection cancel];
    }
    current_command = PORTAL_COMMAND_NONE;
}

- (void)handleTimeOut:(NSTimer*)timer
{
    if (connection_init) {
        [connection cancel];
    }
    [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_TIMEOUT];
}

-(void)StartLogin:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username loginPwd:(NSString*)loginPwd{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_LOGIN;
    stage = PORTAL_STAGE_LOGIN;
    
    loginPwd = [loginPwd md5];
    NSString *body = [NSString stringWithFormat:@"loginName=%@&loginPwd=%@",username,loginPwd];
    
    [self sendPostRequest:@"/user/login" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}

-(void)modifypwd:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd confirmpwd:(NSString *)confirmpwd{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_MODIFY_PWD;
    stage = PORTAL_STAGE_MODIFY_PWD;
    
    oldpwd = [oldpwd md5];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:oldpwd,@"oldPwd",newpwd,@"newPwd",confirmpwd,@"newPwdConfirm", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&oldPwd=%@&newPwd=%@&newPwdConfirm=%@&sig=%@",username,oldpwd,newpwd,confirmpwd,sigstr];
    
    [self sendPostRequest:@"/profile/changePwd" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}

-(void)ModifyPetinfo:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid nickname:(NSString*)nickname sex:(int)sex breed:(int)breed age:(NSNumber*)age height:(NSString*)height weight:(NSString*)weight district:(NSString*)district placeoftengo:(NSString*)placeoftengo{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_MODIFY_PETINFO;
    stage = PORTAL_STAGE_MODIFY_PETINFO;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc] init];
    if (nickname) {
        [paramedict setObject:nickname forKey:@"nickname"];
    }
    [paramedict setObject:[NSString stringWithFormat:@"%d",sex] forKey:@"sex"];
    [paramedict setObject:[NSString stringWithFormat:@"%d",breed] forKey:@"breed"];
    if (age) {
        [paramedict setObject:[age stringValue] forKey:@"birthday"];
    }
    if (height) {
        [paramedict setObject:height forKey:@"height"];
    }
    if (weight) {
        [paramedict setObject:weight forKey:@"weight"];
    }
    if (district) {
        [paramedict setObject:district forKey:@"district"];
    }
    if (placeoftengo) {
        [paramedict setObject:placeoftengo forKey:@"placeoftengo"];
    }
    
    
    if (petid != 0) {
        [paramedict setObject:[[NSString alloc]initWithFormat:@"%ld",petid] forKey:@"petid"];
    }
    NSString *sigstr = [self getsigstr:paramedict];
    
//    NSString *body = [NSString stringWithFormat:@"username=%@&sig=%@&nickname=%@&sex=%d&breed=%d&birthday=%@&height=%f&weight=%f&district=%@&placeoftengo=%@",username,sigstr,nickname,sex,breed,[age stringValue],[height floatValue],[weight floatValue],district,placeoftengo];
//    
    NSMutableString *paramBody = [NSMutableString stringWithString:@""];
    [paramedict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [paramBody appendFormat:@"%@=%@&", key, obj];
    }];
    [paramBody appendFormat:@"username=%@&", username];
    [paramBody appendFormat:@"sig=%@", sigstr];
    NSLog(@"param string: %@", paramBody);
//    if (petid != 0) {
//        body = [NSString stringWithFormat:@"%@&petid=%ld", paramBody, petid];
//    }
    
    [self sendPostRequest:@"/petinfo/modify" body:[paramBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}

-(void)getpetuserlist:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username {
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_PETLIST;
    stage = PORTAL_STAGE_GET_PETLIST;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]init];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&sig=%@",username,sigstr];
    
    [self sendPostRequest:@"/petinfo/getpets" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void)getpetdetail:(id)callback_object selector:(SEL)callback_selector petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_PETDETAIL;
    stage = PORTAL_STAGE_GET_PETDETAIL;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"petid=%ld&sig=%@",petid,sigstr];
    
    [self sendPostRequest:@"/petinfo/getpetdetail" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)getrecommendpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_RECOMMENDPETS;
    stage = PORTAL_STAGE_GET_RECOMMENDPETS;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]init];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&sig=%@",username,sigstr];
    
    [self sendPostRequest:@"/community/getrecommendpets" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void)getnearbypets:(id)callback_object selector:(SEL)callback_selector longitude:(float)longitude latitude:(float)latitude petId:(NSString*)petId
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_NEARBYPETS;
    stage = PORTAL_STAGE_GET_NEARBYPETS;
    
    NSString *stringlongitude = [NSString stringWithFormat:@"%f",longitude];
    NSString *stringlatitude = [NSString stringWithFormat:@"%f",latitude];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringlongitude ,@"longitude",stringlatitude,@"latitude", petId, @"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"petid=%@&longitude=%f&latitude=%f&sig=%@",petId, longitude,latitude,sigstr];
    
    [self sendPostRequest:@"/community/getnearbypets" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void)getconcernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_CONCERNPETS;
    stage = PORTAL_STAGE_GET_CONCERNPETS;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]init];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&sig=%@",username,sigstr];
    
    [self sendPostRequest:@"/community/getconcernpets" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void)concernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_CONCERN_PETS;
    stage = PORTAL_STAGE_CONCERN_PETS;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid, sigstr];
    
    [self sendPostRequest:@"/community/concernpet" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)unconcernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_UNCONCERN_PETS;
    stage = PORTAL_STAGE_UNCONCERN_PETS;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid, sigstr];
    
    [self sendPostRequest:@"/community/unconcernpet" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)leavemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid content:(NSString *)content
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_LEAVE_MSG;
    stage = PORTAL_STAGE_LEAVE_MSG;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid",content,@"content", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&content=%@&sig=%@",username,petid,content, sigstr];
    
    [self sendPostRequest:@"/community/leavemsg" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)getleavemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_LEAVEMSG;
    stage = PORTAL_STAGE_GET_LEAVEMSG;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid, sigstr];
    
    [self sendPostRequest:@"/community/getleavemsgs" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)replymsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username content:(NSString *)content msgid:(long)msgid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_REPLY_MSG;
    stage = PORTAL_STAGE_REPLY_MSG;
    
    NSString *stringmsgid = [NSString stringWithFormat:@"%ld",msgid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:content,@"content",stringmsgid,@"msgid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&content=%@&msgid=%ld&sig=%@",username,content,msgid,sigstr];
    
    [self sendPostRequest:@"/community/replymsg" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)deletemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username msgid:(long)msgid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_DEL_MSG;
    stage = PORTAL_STAGE_DEL_MSG ;
    
    NSString *stringmsgid = [NSString stringWithFormat:@"%ld",msgid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringmsgid,@"msgid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&msgid=%ld&sig=%@",username,msgid,sigstr];
    
    [self sendPostRequest:@"/community/delmsg" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)getleavemsgdetail:(id)callback_object selector:(SEL)callback_selector msgid:(long)msgid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_LEAVEMSG_DETAIL;
    stage = PORTAL_STAGE_GET_LEAVEMSG_DETAIL ;
    
    NSString *stringmsgid = [NSString stringWithFormat:@"%ld",msgid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringmsgid,@"msgid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"msgid=%ld&sig=%@",msgid,sigstr];
    
    [self sendPostRequest:@"/community/getleavemsgdetail" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)getblacklist:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_BLACKLIST;
    stage = PORTAL_STAGE_GET_BLACKLIST ;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]init];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&sig=%@",username,sigstr];
    
    [self sendPostRequest:@"/community/getblacklist" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)addblacklist:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_ADD_BLACKLIST;
    stage = PORTAL_STAGE_ADD_BLACKLIST;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid,sigstr];
    
    [self sendPostRequest:@"/community/addblacklist" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)deleteblacklist:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_DEL_BLACKLIST;
    stage = PORTAL_STAGE_DEL_BLACKLIST;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid,sigstr];
    
    [self sendPostRequest:@"/community/delblacklist" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)searchpets:(id)callback_object selector:(SEL)callback_selector phone:(NSString *)phone
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_SEARCH_PETS;
    stage = PORTAL_STAGE_SEARCH_PETS;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:phone,@"phone", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"phone=%@&sig=%@",phone,sigstr];
    
    [self sendPostRequest:@"/petinfo/searchpets" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)uploadimage:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid imagepath:(NSString *)imagepath
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_UPLOAD_IMAGE;
    stage = PORTAL_STAGE_UPLOAD_IMAGE;
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:imagepath]);//[NSData dataWithContentsOfFile:imagepath];
    NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    
	[post_dict setObject:username forKey:@"username"];
    if (petid != 0) {
        [post_dict setObject:[NSNumber numberWithUnsignedLong:petid] forKey:@"petid"];
    }
    [post_dict setObject:imageData forKey:@"avatar_file"];
    
    filename = @"avatar_file";
	
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
    [self sendPostRequest:@"/petinfo/uploadavatar" body:postData];
}

-(void)uploadgalleryimage:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username galleryid:(long)galleryid imagepath:(NSString *)imagepath name:(NSString *)name type:(NSString *)type description:(NSString *)description{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_UPLOAD_GALLERYIMAGE;
    stage = PORTAL_STAGE_UPLOAD_GALLERYIMAGE;
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:imagepath]);//[NSData dataWithContentsOfFile:imagepath];
    NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];

	[post_dict setObject:imageData forKey:@"photo_file"];
    [post_dict setObject:[NSNumber numberWithUnsignedLong:galleryid] forKey:@"galleryid"];
    [post_dict setObject:username forKey:@"username"];
    [post_dict setObject:@"" forKey:@"name"];
    [post_dict setObject:@"" forKey:@"type"];
    if (!description) {
        [post_dict setObject:@"" forKey:@"description"];
    }else{
        [post_dict setObject:description forKey:@"description"];
    }
    
    filename = @"photo_file";
    
	
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
    [self sendPostRequest:@"/gallery/uploadphoto" body:postData];
}

-(void)getgallerylist:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_GALLERYLIST;
    stage = PORTAL_STAGE_GET_GALLERYLIST;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",petid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"petid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&petid=%ld&sig=%@",username,petid,sigstr];
    
    [self sendPostRequest:@"/gallery/getgalleries" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)getgallery:(id)callback_object selector:(SEL)callback_selector galleryid:(long)galleryid{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_GET_GALLERY;
    stage = PORTAL_STAGE_GET_GALLERY;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",galleryid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"galleryid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"galleryid=%ld&sig=%@",galleryid,sigstr];
    
    [self sendPostRequest:@"/gallery/getgallery" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)creategallery:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username title:(NSString *)title{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_CREATE_GALLERY;
    stage = PORTAL_STAGE_CREATE_GALLERY;
    
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:title,@"title", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&title=%@&sig=%@",username,title,sigstr];
    
    [self sendPostRequest:@"/gallery/creategallery" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)modifygalleryinfo:(id)callback_object selector:(SEL)callback_selector galleryid:(long)galleryid coverurl:(NSString *)coverurl
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_MODIFY_GALLERYINFO;
    stage = PORTAL_STAGE_MODIFY_GALLERYINFO;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",galleryid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:stringpetid,@"galleryid",coverurl,@"coverurl", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"galleryid=%ld&coverurl=%@&sig=%@",galleryid,coverurl,sigstr];
    
    [self sendPostRequest:@"/gallery/setgalleryinfo" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)deletephoto:(id)callback_object selector:(SEL)callback_selector photoid:(long)photoid username:(NSString *)username
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_DELETE_PHOTO;
    stage = PORTAL_STAGE_DELETE_PHOTO;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",photoid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:username,@"username",stringpetid,@"photoid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&photoid=%ld&sig=%@",username,photoid,sigstr];
    
    [self sendPostRequest:@"/gallery/delphoto" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)deletegallery:(id)callback_object selector:(SEL)callback_selector galleryid:(long)galleryid username:(NSString *)username
{
    timeout_timer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(handleTimeOut:) userInfo:nil repeats:NO];
    portal_result_callback_object = callback_object;
    portal_result_callback_selector = callback_selector;
    if (current_command != PORTAL_COMMAND_NONE) {
        [self portalResult:PORTAL_RESULT_FAILED error:PORTAL_ERROR_NETWORK];
        return;
    }
    current_command = PORTAL_COMMAND_DELETE_GALLERY;
    stage = PORTAL_STAGE_DELETE_GALLERY;
    
    NSString *stringpetid = [NSString stringWithFormat:@"%ld",galleryid];
    NSMutableDictionary *paramedict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:username,@"username",stringpetid,@"galleryid", nil];
    NSString *sigstr = [self getsigstr:paramedict];
    
    NSString *body = [NSString stringWithFormat:@"username=%@&galleryid=%ld&sig=%@",username,galleryid,sigstr];
    
    [self sendPostRequest:@"/gallery/delgallery" body:[body dataUsingEncoding:NSUTF8StringEncoding]];
}

//生成sig签名
-(NSString*)getsigstr:(NSDictionary *)pParameter{
    // create need to signature parameter data array
    NSMutableArray *_parameterDataArray = [[NSMutableArray alloc] init];
    
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    
    NSString *userkey = userBean.userKey;
    // init need to signature parameter data array
    [pParameter enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [_parameterDataArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    // append user name to post body data array and add to http request post body
    
    [_parameterDataArray addObject:[NSString stringWithFormat:@"%@=%@", @"username", userBean.name]];
    NSLog(@"post body data array = %@", _parameterDataArray);
    
    // sort parameter data array
    NSMutableArray *_sortedParameterDataArray = [[NSMutableArray alloc] initWithArray:[_parameterDataArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    NSLog(@"sorted post body data array = %@", _sortedParameterDataArray);
    
    // append userKey to sort parameter data array
    if(userkey){
        [_sortedParameterDataArray addObject:userkey];
    }
    NSLog(@"after append user key, sorted post body data array = %@", _sortedParameterDataArray);
    
    // generate signature
    NSString *_signature = [[_sortedParameterDataArray toStringWithSeparator:nil] md5];
    NSLog(@"the signature is %@", _signature);
    [_sortedParameterDataArray release];
    return _signature;
}

//上传图片时，生成对应body
- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = BOUNDARY;
    NSMutableData *body = [NSMutableData data];
    NSArray* keys = [dict allKeys];
    
    for (int i = 0; i < [keys count]; i++) {
        if (![[keys objectAtIndex:i] isEqualToString:filename]) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[dict valueForKey:[keys objectAtIndex:i]] isKindOfClass:[NSNumber class]]) {
                [body appendData:[[NSString stringWithFormat:@"%d\r\n", [[dict valueForKey:[keys objectAtIndex:i]]intValue]] dataUsingEncoding:NSUTF8StringEncoding]];
            }else{
                [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dict valueForKey:[keys objectAtIndex:i]]] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
        }
    }
    
    // add image data
    if ([dict objectForKey:filename]) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[dict objectForKey:filename]];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}
@end
