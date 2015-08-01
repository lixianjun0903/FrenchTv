//
//  ECMessageBody.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/17.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 消息体类型枚举
 */
typedef NS_ENUM(NSInteger, MessageBodyType) {
    
    /** 文本消息 */
    MessageBodyType_Text = 1,
    
    /** 多媒体消息 */
    MessageBodyType_Media,
    
    /** chunk语音消息 */
    MessageBodyType_ChunkVoice
};

/**
 * 消息体基类
 */
@interface ECMessageBody : NSObject
/**
 @brief 消息体的类型
 */
@property (nonatomic, readonly) MessageBodyType messageBodyType;

@end
