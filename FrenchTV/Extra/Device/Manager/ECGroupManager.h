//
//  ECGroupManager.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ECManagerBase.h"
#import "ECGroup.h"
#import "ECGroupMatch.h"
#import "ECGroupMember.h"
#import "ECEnumDefs.h"
#import "ECGroupOption.h"

/**
 * 群组管理类
 * 包含有关群组操作函数
 */
@protocol ECGroupManager <ECManagerBase>

/**
 @brief 创建群组
 @param group 创建的群组信息 只需关注group中name、declared、type、mode
 @param completion 执行结果回调block
 */
-(void)createGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion;

/**
 @brief 修改群组
 @param group 修改的群组信息
 @param completion 执行结果回调block
 */
-(void)modifyGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion;


/**
 @brief 删除群组
 @param groupId 删除的群组id
 @param completion 执行结果回调block
 */
-(void)deleteGroup:(NSString*)groupId completion:(void(^)(ECError *error, NSString* groupId))completion;


/**
 @brief 获取所有公共群组
 @param lastUpdateTime 时间点, UTC时间, 以毫秒为单位
        (NSDate返回的timeInterval是以秒为单位的, 如果使用NSDate, 比如 timeIntervalSince1970 方法，需要将 timeInterval 乘以1000)
 @param completion 执行结果回调block
 */
-(void)getAllPublicGroups:(NSString*)lastUpdateTime completion:(void(^)(ECError* error, NSString* updateTime,
                                                                        NSArray *groups))completion;

/**
 @brief 按条件搜索公共群组
 @param match 需要匹配的条件
 @param completion 执行结果回调block
 */
-(void)searchPublicGroups:(ECGroupMatch *)match completion:(void(^)(ECError *error, NSArray* groups))completion;


/**
 @brief 获取群组属性
 @param groupId 获取信息的群组id
 @param completion 执行结果回调block
 */
-(void)getGroupDetail:(NSString *)groupId completion:(void(^)(ECError *error ,ECGroup *group))completion;


/**
 @brief 用户申请加入群组
 @param groupId 申请加入的群组Id
 @param reason 申请加入的理由
 @param completion 执行结果回调block
 */
-(void)joinGroup:(NSString*)groupId reason:(NSString*)reason completion:(void(^)(ECError *error, NSString* groupId))completion;


/**
 @brief 管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param reason 邀请理由
 @param members 邀请加入的人
 @param confirm 是否需要对方验证 0:需要对方验证 1:直接加入(不需要验证)
 @param completion 执行结果回调block
 */
-(void)inviteJoinGroup:(NSString *)groupId reason:(NSString*)reason members:(NSArray*)members confirm:(NSInteger)confirm completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion;


/**
 @brief 删除成员
 @param groupId 删除成员的群组id
 @param members 删除的成员
 @param completion 执行结果回调block
 */
-(void)deleteGroupMembers:(NSString*)groupId members:(NSArray*)members completion:(void(^)(ECError* error, NSString* groupId, NSArray* members))completion;


/**
 @brief 退出群组
 @param groupId 退出的群组id
 @param completion 执行结果回调block
 */
-(void)quitGroup:(NSString*)groupId completion:(void(^)(ECError* error, NSString* groupId))completion;


/**
 @brief 修改群组成员名片
 @param member 修改的成员名片
 @param completion 执行结果回调block
 */
-(void)modifyMemberCard:(ECGroupMember *)member completion:(void(^)(ECError *error, ECGroupMember* member))completion;


/**
 @brief 查询群组成员名片
 @param memberId 查询的成员id
 @param groupId 成员所属群组id
 @param completion 执行结果回调block
 */
-(void)queryMemberCard:(NSString *)memberId belong:(NSString*)groupId completion:(void(^)(ECError *error, ECGroupMember *member))completion;


/**
 @brief 查询群组成员
 @param groupId 查询的群组id
 @param completion 执行结果回调block
 */
-(void)queryGroupMembers:(NSString*)groupId completion:(void(^)(ECError *error, NSArray* members))completion;


/**
 @brief 查询加入的群组
 @param completion 执行结果回调block
 */
-(void)queryOwnGroups:(void(^)(ECError *error, NSArray *groups))completion;


/**
 @brief 管理员对成员禁言
 @param groupId 成员所属群组id
 @param memberId 成员id
 @param status 禁言状态
 @param completion 执行结果回调block
 */
-(void)forbidMemberSpeakStatus:(NSString*)groupId member:(NSString*)memberId speakStatus:(ECSpeakStatus)status completion:(void(^)(ECError *error, NSString* groupId, NSString* memberId))completion;


/**
 @brief 管理员验证用户申请加入群组
 @param groupId 申请加入的群组id
 @param memberId 申请加入的成员id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackJoinGroupRequest:(NSString *)groupId member:(NSString*)memberId ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId, NSString* memberId))completion;


/**
 @brief 用户验证管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackInviteJoinGroupRequest:(NSString*)groupId ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId))completion;


/**
 @brief 成员设置群组消息接收规则
 @param option 群组消息接收规则
 @param completion 执行结果回调block
 */
-(void)setGroupMessageOption:(ECGroupOption*)option completion:(void(^)(ECError* error, NSString* groupId))completion;

@end