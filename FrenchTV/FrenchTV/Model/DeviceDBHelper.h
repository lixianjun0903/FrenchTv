//
//  DeviceDBHelper.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECGroupNoticeMessage.h"
#import "IMMsgDBAccess.h"

#define KNotification_DeleteLocalSessionMessage @"KNotification_DeleteLocalSessionMessage"

@interface DeviceDBHelper : NSObject
@property (nonatomic, strong) IMMsgDBAccess *msgDBAccess;

//获取句柄
+(DeviceDBHelper*)sharedInstance;

//获取会话中最新消息100条
-(NSArray*)getLatestHundredMessageOfSessionId:(NSString*)sessionId;

//删除会话的数据
-(void)deleteAllMessageOfSession:(NSString*)sessionId;

//获取自定义会话列表
-(NSArray*)getMyCustomSession;

//获取Group通知消息
-(NSArray*)getLatestHundredGroupNotice;

//打开数据库
-(void)openDataBasePath:(NSString*)voip;
@end
