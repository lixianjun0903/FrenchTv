//
//  ECDelegateBase.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ECError.h"

/**
 * 该代理用于接收登录和注销状态
 */
@protocol ECDelegateBase <NSObject>

@optional

/**
 @brief 登录状态接口
 @discussion 监听与服务器的登录状态
 @param error 连接的状态
 */
-(void)onConnected:(ECError*)error;

/**
 @brief 注销状态接口
 @discussion 监听与服务器注销结果
 @param error 注销结果
 */
-(void)onDisconnect:(ECError*)error;

@required

@end
