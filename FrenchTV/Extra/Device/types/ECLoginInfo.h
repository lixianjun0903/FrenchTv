//
//  ECInitialization.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDeviceDelegate.h"

/**
 * 登录所需信息
 */
@interface ECLoginInfo : NSObject

/**
 @brief account 登录账号（官网上的VoIP账号）
*/
@property (nonatomic, copy, readonly) NSString *account;

/**
 @brief password 登录密码（官网上的VoIP密码）
 */
@property (nonatomic, copy, readonly) NSString *password;

/**
 @brief subAccount 登录子账号
 */
@property (nonatomic, copy) NSString *subAccount;

/**
 @brief subToken 登录子账号鉴权
 */
@property (nonatomic, copy) NSString *subToken;

/**
 @brief serviceUrl 服务器地址 默认地址为sandboxapp.cloopen.com:8883
 */
@property (nonatomic, copy) NSString *serviceUrl;

/**
 @brief 创建登录
 @param account 登录账号
 @param password 登录密码
 @return 返回实例
 */
- (instancetype)initWithAccount:(NSString*)account Password:(NSString*)password;
@end
