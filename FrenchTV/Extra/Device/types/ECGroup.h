//
//  ECGroupInfo.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 群组的类型
 */
typedef NS_ENUM(NSUInteger, ECGroupType){
    
    /** 临时组(上限100人)  */
    ECGroupType_Temp,
    
    /** 1：普通组(上限300人) */
    ECGroupType_Normal,
    
    /** VIP组 (上限500人) */
    ECGroupType_VIP
} ;


/**
 * 群组加入模式
 */
typedef NS_ENUM(NSUInteger,ECGroupPermMode){
    
    /** 默认直接加入 */
    ECGroupPermMode_DefaultJoin,
    
    /** 需要身份验证 */
    ECGroupPermMode_NeedIdAuth,
    
    /** 私有群组 */
    ECGroupPermMode_PrivateGroup
} ;


/**
 * 群组信息类
 */
@interface ECGroup : NSObject

/**
 @property
 @brief groupId 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 @property
 @brief owner 群组所有者（创建者）
 */
@property (nonatomic, copy) NSString *owner;

/**
 @property
 @brief createdTime 群组创建时间
 */
@property (nonatomic, copy) NSString *createdTime;

/**
 @property
 @brief name 群组名称
 */
@property (nonatomic, copy) NSString *name;

/**
 @property
 @brief members 群成员
 */
@property (nonatomic, strong) NSArray *members;

/**
 @property
 @brief declared 群公告
 */
@property (nonatomic, copy) NSString *declared;

/**
 @property
 @brief mode 群组加入的模式
 */
@property (nonatomic, assign) ECGroupPermMode mode;

/**
 @property
 @brief type 群类型
 */
@property (nonatomic, assign) ECGroupType type;

/**
 @property
 @brief count 群个数
 */
@property (nonatomic, assign) NSInteger count;

/**
 @method
 @brief 初始化
 @param groupId 群组id
 */
-(ECGroup *)initWithID:(NSString *)groupId;

@end
