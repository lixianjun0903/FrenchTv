//
//  DeviceDelegateHelper.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDeviceHeaders.h"


#define KNOTIFICATION_onConnected       @"KNOTIFICATION_onConnected"
#define KNOTIFICATION_onDisconnected    @"KNOTIFICATION_onDisconnected"

#define KNOTIFICATION_onNetworkChanged    @"KNOTIFICATION_onNetworkChanged"

#define KNOTIFICATION_onMesssageChanged    @"KNOTIFICATION_onMesssageChanged"
#define KNOTIFICATION_onRecordingAmplitude    @"KNOTIFICATION_onRecordingAmplitude"

#define KNOTIFICATION_onReceivedGroupNotice    @"KNOTIFICATION_onReceivedGroupNotice"
@interface DeviceDelegateHelper : NSObject<ECDeviceDelegate>
/**
 *@brief 获取DeviceDelegateHelper单例句柄
 */

+(DeviceDelegateHelper*)sharedInstance;

@end
