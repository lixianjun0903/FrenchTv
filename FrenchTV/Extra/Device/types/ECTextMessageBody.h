//
//  ECTextMessageBody.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/17.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ECMessageBody.h"

/**
 * 文本消息体
 */
@interface ECTextMessageBody : ECMessageBody
/**
 @brief text 文本消息体的内部文本对象的文本
 */
@property (nonatomic, strong) NSString *text;

/**
 @brief serverTime 时间
 */
@property (nonatomic, strong) NSString *serverTime;

/**
 @brief 创建文本实例
 @param text 文本消息
 */
-(instancetype)initWithText:(NSString*)text;

@end
