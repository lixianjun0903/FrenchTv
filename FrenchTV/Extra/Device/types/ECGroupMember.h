//
//  ECGroupMember.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/7.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECEnumDefs.h"

/**
 * 群组成员类
 */
@interface ECGroupMember : NSObject

/**
 @property
 @brief memberId 成员ID
 */
@property (nonatomic, copy) NSString *memberId;

/**
 @property
 @brief display 显示的名字
 */
@property (nonatomic, copy) NSString *display;

/**
 @property
 @brief tel 电话
 */
@property (nonatomic, copy) NSString *tel;

/**
 @property
 @brief mail 邮箱
 */
@property (nonatomic, copy) NSString *mail;

/**
 @property
 @brief remark 备注
 */
@property (nonatomic, copy) NSString *remark;

/**
 @property
 @brief groupId 所属的群组ID
 */
@property (nonatomic, copy) NSString *groupId;

/**
 @property
 @brief speakStatus 说话限制
 */
@property (nonatomic, assign) ECSpeakStatus speakStatus;
@end
