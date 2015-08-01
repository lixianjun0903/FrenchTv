//
//  ECChatDelegate.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDelegateBase.h"
#import "ECMessage.h"
#import "ECReport.h"

/**
 * 该代理主要用户接收即时消息和消息的回执报告
 */
@protocol ECChatDelegate <ECDelegateBase>
@optional

/**
 @brief 客户端录音振幅代理函数
 @param amplitude 录音振幅
 */
-(void)onRecordingAmplitude:(double) amplitude;

/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveMessage:(ECMessage*)message;

/**
 @brief 接收消息回执
 @param report 回执报告
 */
-(void)onReceivedReport:(ECReport*)report;
@required

@end