//
//  ECReport.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 消息发送到达报告
 */
@interface ECReport : NSObject
/**
 @brief msgId 消息id
 */
@property(nonatomic, strong, readonly) NSString *msgId;

/**
 @brief isAck 是否到达
 */
@property(nonatomic, readonly) BOOL isAck;


/**
 @brief	生成报告
 @param amsgId 	消息id
 @param aIsAck 	是否到达
 @return 消息报告
 */
+(ECReport*)reportWithMsgId:(NSString*)amsgId andIsAck:(BOOL)aIsAck;

@end
