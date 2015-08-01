//
//  ECDeviceDelegate.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/13.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDelegateBase.h"
#import "ECNetworkDelegate.h"
#import "ECMessageDelegate.h"

/**
 * SDK消息接收代理
 * 设置代理用于接收网络消息、与平台连接消息、接收对方消息等SDK上报的消息；
 */
@protocol ECDeviceDelegate <ECNetworkDelegate,ECMessageDelegate>

@required
@end