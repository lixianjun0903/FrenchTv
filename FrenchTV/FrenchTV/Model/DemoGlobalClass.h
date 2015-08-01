//
//  DemoGlobalClass.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceChatHelper.h"
#import "DeviceDBHelper.h"
//#import "PersonModel.h"
#import <UIKit/UIKit.h>

#define voipKey         @"voip_account"
#define pwdKey          @"voip_token"
#define nameKey         @"voip_name"
#define imageKey        @"image_key"
#define subAccountKey   @"sub_account"
#define subTokenKey     @"sub_token"

#define UserDefault_Connacts    @"UserDefault_Connacts"
#define UserDefault_LoginUser   @"UserDefault_LoginUser"

#define KNotice_GetGroupName  @"KNotice_GetGroupName"

@class ECLoginInfo;

@interface DemoGlobalClass : NSObject
@property (nonatomic,strong)ECLoginInfo * loginInfo;
@property (nonatomic,strong)NSMutableDictionary * userInfoDic;

/**
 *@brief 获取DemoGlobalClass单例句柄
 */
+(DemoGlobalClass*)sharedInstance;


/**
 *@brief 主账号信息
 */
@property (nonatomic, strong) NSMutableDictionary* mainAccontDictionary;

/**
 *@brief 测试应用下子账号信息
 */
@property (nonatomic, strong) NSMutableArray* subAccontsArray;

/**
 *@brief 测试应用下子账号信息
 */
@property (nonatomic, strong) NSDictionary* loginInfoDic;

/**
 *@brief 测试应用信息
 */
@property (nonatomic, strong) NSMutableDictionary* appInfoDictionary;

@property (nonatomic, strong) NSMutableDictionary* allSessions;

//是否已经登录
@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, assign) ECNetworkType netType;
/**
 *@brief 根据VoIP获取联系人姓名
 *@param voip 联系人VoIP
 */
-(NSString*)getOtherNameWithVoip:(NSString*)voip;

/**
 *@brief 根据VoIP获取联系人信息
 *@param voip 联系人VoIP
 */
-(NSMutableDictionary*)getOtherDictionaryWithVoip:(NSString*)voip;

/**
 *@brief 根据VoIP获取联系人头像
 *@param voip 联系人VoIP、群组id
 */
-(UIImage*)getOtherImageWithVoip:(NSString*)voip;
@end
