//
//  ECManager.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECMessageManager.h"
#import "ECDeviceDelegate.h"
#import "ECLoginInfo.h"
#import "ECError.h"

#import "ECDeviceHeaders.h"

/**
 * 设备类 使用该类的单例操作
 */
@interface ECDevice : NSObject

/**
 @brief 单例
 @discussion 获取该类单例进行操作
 @return 返回类实例
 */
+(ECDevice*)sharedInstance;


/**
 @brief 登录
 @discussion 异步函数，建立与平台的连接
 @param info 登录所需信息
 @param completion 执行结果回调block
 */
-(void)login:(ECLoginInfo *)info completion:(void(^)(ECError* error)) completion;


/**
 @brief 退出登录
 @discussion 异步函数，断开与平台的连接
 @param completion 执行结果回调block
 */
-(void)logout:(void(^)(ECError* error)) completion;


/**
 @brief device代理
 @discussion 用于监听通知事件
 */
@property (nonatomic, assign) id<ECDeviceDelegate> delegate;


/**
 @brief 即时消息管理类
 @discussion 用于群组管理，消息发送，录音、放音等操作
 */
@property (nonatomic, readonly, strong) id<ECMessageManager> messageManager;

@end
