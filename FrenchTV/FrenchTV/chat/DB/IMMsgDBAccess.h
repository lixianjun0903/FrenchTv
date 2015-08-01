/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#import "ECMessage.h"
#import "ECGroupNoticeMessage.h"
#import "ECMediaMessageBody.h"

@interface IMMsgDBAccess : NSObject

- (IMMsgDBAccess *)initWithName:(NSString*)name;

#pragma mark 消息操作API
//获取会话列表
-(NSArray*)loadAllSessions;

//搜索文本聊天记录
-(NSArray*)searchTextLike:(NSString*)text;

//增加单条消息
-(BOOL)addMessage:(ECMessage*)message;

//增加多条消息
-(NSInteger)addMessages:(NSArray*)messages;

//删除单条消息
-(BOOL)deleteMessage:(NSString*)msgId;

//删除多条消息
-(NSInteger)deleteMessages:(NSArray*)messages;

//删除某个会话的所有消息
-(NSInteger)deleteMessageOfSession:(NSString*)sessionId;

//清除表数据
-(NSInteger)clearMessageTable;

//获取表中所有未读消息数
-(NSInteger)getUnreadMessageCount;

//获取某个会话的未读消息数
-(NSInteger)getUnreadMessageCountOfSession:(NSString*)sessionId;

//获取表中消息数
-(NSInteger)getMessageCount;

//获取某个会话的消息数
-(NSInteger)getMessageCountOfSession:(NSString*)sessionId;

//获取会话的某个时间点之前的count条消息
-(NSArray*)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId beforeTime:(long long)timesamp;

//获取会话的某个时间点之后的count条消息
-(NSArray*)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId afterTime:(long long)timesamp;

//获取某会话最新的消息
-(ECMessage*)getLatestMessageOfSession:(NSString*)sessionId;

//设置会话的所有消息已读
-(NSInteger)markMessagesAsReadOfSession:(NSString*)sessionId;

//设置某条消息的阅读状态
-(BOOL)markMessage:(NSString*)msgId asRead:(BOOL)isRead;

//更新某消息的状态
-(BOOL)updateState:(ECMessageState)state ofMessageId:(NSString*)msgId;

//更新某消息的下载状态
-(BOOL)updateDownloadState:(ECMediaDownloadStatus)state ofMessageId:(NSString*)msgId;

//重发，更新某消息的消息id
-(BOOL)updateMessageId:(NSString*)msdNewId ofMessageId:(NSString*)msgOldId;

//修改单条消息的下载路径和下载状态
-(BOOL)updateMessageLocalPath:(NSString*)msgId withPath:(NSString*)path;

//判断消息是否存在
- (BOOL)isMessageExistOfMsgid:(NSString*)msgid;
#pragma mark 群组消息操作API

//增加一条消息
-(BOOL)addGroupMessage:(ECGroupNoticeMessage*)message;

//增加多条消息
-(NSInteger)addGroupMessages:(NSArray*)messages;

-(NSInteger)addGroupIDs:(NSArray*)messages;

-(NSString *)getGroupNameOfId:(NSString *)groupId;
//删除关于某群组的所有消息
-(NSInteger)deleteGroupMessagesOfGroup:(NSString*)groupId;

//清空表
-(NSInteger)clearGroupMessageTable;

//获取表中所有未读消息数
-(NSInteger)getUnreadGroupMessageCount;

//获取确定群组的未读消息数
-(NSInteger)getUnreadGroupMessageCountOfGroup:(NSString*)groupId;

//获取表中消息数
-(NSInteger)getAllGroupMessageCount;

//获取表中确定群组消息数
-(NSInteger)getAllGroupMessageCountOfGroup:(NSString*)groupId;

//获取某个时间点之前的count条数据
-(NSArray*)getSomeGroupMessagesCount:(NSInteger)count beforeTime:(long long)timesamp;

//获取群组中某个时间点之前的count条数据
-(NSArray*)getSomeGroupMessagesCount:(NSInteger)count OfGroup:(NSString*)group beforeTime:(long long)timesamp;

//标记某群组中所有消息已读
-(NSInteger)markGroupMessagesAsReadOfGroup:(NSString*)groupId;

//标记表中所有消息已读
-(NSInteger)markGroupMessagesAsRead;

@end
