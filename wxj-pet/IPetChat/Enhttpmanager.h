//
//  Enhttpmanager.h
//  IPetChat
//
//  Created by WXJ on 13-11-11.
//  Copyright (c) 2013年 XF. All rights reserved.
//

//#import <Foundation/Foundation.h>

typedef enum {
    PORTAL_RESULT_FAILED,
    PORTAL_RESULT_ALREADY,
    PORTAL_RESULT_LOGIN_SUCCESS,
    PORTAL_RESULT_LOGOUT_SUCCESS,
    PORTAL_RESULT_GET_PETLIST_SUCCESS,
    PORTAL_RESULT_MODIFY_PETINFO_SUCCESS,
    PORTAL_RESULT_GET_RECOMMENDPETS_SUCCESS,
    PORTAL_RESULT_GET_NEARBYPETS_SUCCESS,
    PORTAL_RESULT_GET_CONCERNPETS_SUCCESS,
    PORTAL_RESULT_CONCERN_PETS_SUCCESS,
    PORTAL_RESULT_UNCONCERN_PETS_SUCCESS,
    PORTAL_RESULT_LEAVE_MSG_SUCCESS,
    PORTAL_RESULT_GET_LEAVEMSG_SUCCESS,
    PORTAL_RESULT_REPLY_MSG_SUCCESS,
    PORTAL_RESULT_DEL_MSG_SUCCESS,
    PORTAL_RESULT_GET_LEAVEMSG_DETAIL_SUCCESS,
    PORTAL_RESULT_GET_BLACKLIST_SUCCESS,
    PORTAL_RESULT_ADD_BLACKLIST_SUCCESS,
    PORTAL_RESULT_DEL_BLACKLIST_SUCCESS,
    PORTAL_RESULT_SEARCH_PETS_SUCCESS,
    PORTAL_RESULT_UPLOAD_IMAGE_SUCCESS,
    PORTAL_RESULT_GET_PETDETAIL_SUCCESS,
    PORTAL_RESULT_MODIFY_PWD_SUCCESS,
    PORTAL_RESULT_GET_GALLERYLIST_SUCCESS,
    PORTAL_RESULT_GET_GALLERY_SUCCESS,
    PORTAL_RESULT_UPLOAD_GALLERYIMAGE_SUCCESS,
    PORTAL_RESULT_CREATE_GALLERY_SUCCESS,
    PORTAL_RESULT_MODIFY_GALLERYINFO_SUCCESS,
    PORTAL_RESULT_DELETE_PHOTO_SUCCESS,
    PORTAL_RESULT_DELETE_GALLERY_SUCCESS
} PORTAL_RESULT;

typedef enum {
    PORTAL_ERROR_OK,
    PORTAL_ERROR_HTML,
    PORTAL_ERROR_NETWORK,
    PORTAL_ERROR_TIMEOUT,
    PORTAL_ERROR_NOT_VALID_USER,
    PORTAL_ERROR_CONCERN_PETS
} PORTAL_ERROR;

@interface Enhttpmanager : NSObject

+ (Enhttpmanager*)sharedSingleton;
- (void)checkOnlineStatus:(id)callback_object selector:(SEL)callback_selector;
- (void)cancelHttpConnection;
//获取宠物列表
- (void)getpetuserlist:(id)callback_object selector:(SEL)callback_selector username:(NSString*)username;
//登录
-(void)StartLogin:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username loginPwd:(NSString*)loginPwd;
//修改宠物信息
-(void)ModifyPetinfo:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid nickname:(NSString*)nickname sex:(int)sex breed:(int)breed age:(NSString*)age height:(NSString*)height weight:(NSString*)weight district:(NSString*)district placeoftengo:(NSString*)placeoftengo;
//获取推荐宠物
-(void)getrecommendpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username;
//获取推荐宠物
-(void)getnearbypets:(id)callback_object selector:(SEL)callback_selector longitude:(float)longitude latitude:(float)latitude;
//获取关注的宠物
-(void)getconcernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username;
//关注宠物
-(void)concernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid;
//取消关注
-(void)unconcernpets:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid;
//留言
-(void)leavemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid content:(NSString*)content;
//获取留言列表
-(void)getleavemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username petid:(long)petid;
//回复留言
-(void)replymsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username content:(NSString*)content msgid:(long)msgid;
//删除留言
-(void)deletemsg:(id)callback_object selector:(SEL)callback_selector username:(NSString *)username msgid:(long)msgid;
//获取留言详情
-(void)getleavemsgdetail:(id)callback_object selector:(SEL)callback_selector  msgid:(long)msgid;
//获取黑名单
-(void)getblacklist:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username;
//加入黑名单
-(void)addblacklist:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username petid:(long)petid;
//从黑名单中删除
-(void)deleteblacklist:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username petid:(long)petid;
//从黑名单中删除
-(void)searchpets:(id)callback_object selector:(SEL)callback_selector  phone:(NSString *)phone;
//获取宠物详细信息
- (void)getpetdetail:(id)callback_object selector:(SEL)callback_selector petid:(long)petid;
//上传头像
-(void)uploadimage:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username petid:(long)petid imagepath:(NSString*)imagepath;
//修改密码
-(void)modifypwd:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username oldpwd:(NSString*)oldpwd newpwd:(NSString*)newpwd confirmpwd:(NSString*)confirmpwd;
//获取相册列表
-(void)getgallerylist:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username petid:(long)petid;
//获取相册
-(void)getgallery:(id)callback_object selector:(SEL)callback_selector  galleryid:(long)galleryid;
//上传照片
-(void)uploadgalleryimage:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username galleryid:(long)galleryid imagepath:(NSString*)imagepath name:(NSString *)name type:(NSString *)type description:(NSString*)description;
//上传相册
-(void)creategallery:(id)callback_object selector:(SEL)callback_selector  username:(NSString *)username  title:(NSString *)title;
//修改相册信息
-(void)modifygalleryinfo:(id)callback_object selector:(SEL)callback_selector  galleryid:(long)galleryid coverurl:(NSString *)coverurl;
//删除图片
-(void)deletephoto:(id)callback_object selector:(SEL)callback_selector  photoid:(long)photoid username:(NSString *)username;
//删除相册
-(void)deletegallery:(id)callback_object selector:(SEL)callback_selector  galleryid:(long)galleryid username:(NSString *)username;
@end
