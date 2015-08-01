//
//  ECSpeakStatus.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/7.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 网络状态值
 */
typedef NS_ENUM(NSInteger,ECNetworkType) {
    
    /** 当前无网络 */
    ECNetworkType_NONE=0,
    
    /** 当前网络为LAN类型 */
    ECNetworkType_LAN,
    
    /** 当前网络是WIFI */
    ECNetworkType_WIFI,
    
    /**  当前网络是GPRS*/
    ECNetworkType_GPRS,
    
    /** 当前网络是3G */
    ECNetworkType_3G
};

/**
 * 群组成员禁言状态
 */
typedef NS_ENUM(NSInteger,ECSpeakStatus){
    
    /** 允许发言 */
    ECSpeakStatus_Allow=0,
    
    /** 禁止发言 */
    ECSpeakStatus_Forbid
};

/**
 * 验证类型
 */
typedef NS_ENUM(NSInteger,ECAckType) {
    
    /** 同意 */
    EAckType_Agree,
    
    /** 拒绝 */
    EAckType_Reject
};

/**
 * 发送状态
 */
typedef NS_ENUM(NSInteger,ECMessageState) {
    
    /** 发送失败 */
    ECMessageState_SendFail=-1,
    
    /** 发送成功 */
    ECMessageState_SendSuccess=0,
    
    /** 发送中 */
    ECMessageState_Sending=1,
    
    /** 接收成功 */
    ECMessageState_Receive=2,
    
    /**  */
    ECMessageState_Tmpe=3
};
