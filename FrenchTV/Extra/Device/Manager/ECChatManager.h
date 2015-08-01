//
//  ECChatManager.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ECManagerBase.h"
#import "ECMessage.h"
#import "ECError.h"
#import "ECProgressDelegate.h"
#import "ECMediaMessageBody.h"
#import "ECChunkMessageBody.h"


/**
 * 聊天管理类
 * 用于发送消息、录音、播音、下载附件消息等
 */
@protocol ECChatManager <ECManagerBase>

/**
 @brief 发送消息
 @discussion 发送文本消息时，进度不生效；发送附件消息时，进度代理生效
 @param message 发送的消息
 @param progress 发送进度代理
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)sendMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 发送实时语音消息
 @discussion 边录边传模式
 @param msg 发送的消息
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)sendRealTimeMessage:(ECMessage*)msg error:(void(^)(ECError* error, ECMessage* message))error;

/**
 @brief 停止发送实时语音
 @discussion 调用该函数停止录制语音并完成发送
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)stopRealTimeMessage:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 取消发送实时语音
 @discussion 调用该函数取消发送，并发送取消标识
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)cancelRealTimeMessage:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 录制arm音频
 @param msg 音频的消息体
 @param completion 执行结果回调block
 */
-(void)startVoiceRecording:(ECMediaMessageBody*)msg error:(void(^)(ECError* error, ECMediaMessageBody*messageBody))error;

/**
 @brief 停止录制arm音频
 @param completion 执行结果回调block
 */
-(void)stopVoiceRecording:(void(^)(ECError *error, ECMediaMessageBody*messageBody))completion;

/**
 @brief 播放arm音频消息
 @param completion 执行结果回调block
 */
-(void)playVoiceMessage:(ECMediaMessageBody*)msg completion:(void(^)(ECError *error))completion;

/**
 @brief 停止播放音频
 @param completion 执行结果回调block
 */
-(BOOL)stopPlayingVoiceMessage;

/**
 @brief 下载附件消息
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadMediaMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 下载图片文件缩略图
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadThumbnailMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;


/**
 @brief 下载实时语音消息
 @param message 下载的实时语音消息
 @param completion 执行结果回调block
 */
-(void)downloadChunkMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message))completion;

@end
