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

#import "IMMsgDBAccess.h"
#import <UIKit/UIDevice.h>

#import "ECSession.h"
#import "ECTextMessageBody.h"
#import "ECMediaMessageBody.h"
#import "ECChunkMessageBody.h"
#import "DBConnection.h"
#import "Statement.h"
#import "IMCommon.h"
#import "ECGroup.h"



//#import <objc/runtime.h>
@interface IMMsgDBAccess()
{
    sqlite3 * shareDB;
}
@end

@implementation IMMsgDBAccess
- (IMMsgDBAccess *)initWithName:(NSString*)name
{
    if (self=[super init]) {
        shareDB = [DBConnection getSharedDatabaseName:name];
        [self IMMessageTableCreate];
        [self IMGroupNoticeTableCreate];
        [self IMGroupIDTableCreate];
        [self sessionTableCreate];
        [self IMTriggerCreate];
        return self;
    }
    return nil;
}

/*
 会话表
 字段	类型	约束	备注
 ID	int	自增	主键
 sessionId 	Varchar	32	会话id
 dateTime 	Long		显示的时间 毫秒
 type 	int		与消息表msgType一样
 text 	Varchar	2048	显示的内容
 unreadCount	int		未读消息数
 sumCount 	int		总消息数
 */

- (BOOL)sessionTableCreate {
    const char * createTable = "create table if not exists session (ID integer primary key, sessionId varchar(32),dateTime integer,type integer,text varchar(2048),unreadCount integer,sumCount integer,state integer)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or device_info!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

/*
 消息
 ID 	int	自增	主键
 SID	Varchar 	32	会话ID
 msgid	Varchar 	64	消息id 1594129051-ea37ff0-1413864586
 sender	Varchar 	32	发送者
 receiver	Varchar 	32	接收者
 createdTime	Long		入库本地时间 毫秒
 userData	Varchar	256	用户自定义数据
 isRead	bool		是否已读
 msgType	int		消息类型 0:文本 1:多媒体 2:chunk消息 (0-99聊天的消息类型 100-199系统的推送消息类型)
 text	Varchar	2048	文本
 localPath	text		本地路径
 URL	text		下载路径
 state	int		发送状态 -1发送失败 0发送成功 1发送中 2接收成功（默认为0 接收的消息）；
 dstate	int          接收的附件消息下载状态 0未开始下载 1下载中 2下载成功 3下载失败
 serverTime	Long		服务器时间 毫秒
 remark	Varchar	1024	备注
 */
- (BOOL)IMMessageTableCreate {
    const char * createTable = "create table if not exists im_message(ID integer primary key, SID varchar(32),msgid varchar(64),sender varchar(32), receiver varchar(32),createdTime integer,userData varchar(256), isRead bool,msgType integer, text varchar(2048), localPath text, URL text, state integer, serverTime integer,dstate integer,remark varchar(1024))";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_message!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

/*
 群组推送消息表
 字段	类型	约束	备注
 ID	int		自增
 groupId 	Varchar	32	群组id
 type 	int		消息类型
 admin 	Varchar	32	管理员
 member 	Varchar	32	成员
 declared 	Varchar	256	原因
 dateCreated 	Long		服务器的时间 毫秒
 confirm 	int		是否需要确认
 isRead	bool		是否已读
 */
- (BOOL)IMGroupNoticeTableCreate {
    const char * createTable = "create table if not exists im_groupnotice(ID integer primary key,groupId varchar(32),type integer,admin varchar(32),member varchar(32),declared varchar(32), dateCreated integer, confirm integer, isRead bool)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_groupnotice!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (BOOL)IMGroupIDTableCreate {
     const char * createGroupTable = "create table if not exists im_groupinfo(ID integer primary key,groupId varchar(32),type integer,groupname varchar(32));create unique index if not exists idx_x_groupinfo_info on im_groupinfo(groupId)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createGroupTable, NULL, NULL, &errmsg);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to create table Thread or im_groupnotice!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (BOOL)IMTriggerCreate {
    const char * createTrigger = "\
    CREATE TRIGGER delete_obsolete_im AFTER DELETE ON im_message \
    BEGIN DELETE FROM session WHERE sessionId = old.sid;  \
    insert into session(sessionId,dateTime,type,text,state) select sid,createdTime,msgType,text,state from im_message where sid = old.sid ORDER BY createdTime DESC LIMIT 1; UPDATE session SET SumCount = (SELECT COUNT(im_message.id) FROM im_message LEFT JOIN session ON session.sessionId = sid WHERE sid = old.sid ) WHERE session.sessionId = old.sid; UPDATE session SET unreadCount =(SELECT COUNT(im_message.id) FROM im_message WHERE isRead = 0 AND sid = old.sid) WHERE session.sessionId = old.sid; END; CREATE TRIGGER im_update_thread_on_insert AFTER INSERT ON im_message BEGIN delete from session WHERE session.sessionId=new.sid; insert into session(sessionId,dateTime,type,text,state) values (new.sid,new.createdTime,new.msgType,new.text,new.state); UPDATE session SET sumCount = (SELECT COUNT(im_message.id) FROM im_message LEFT JOIN session ON session.sessionId = sid WHERE sid = new.sid) WHERE session.sessionId = new.sid; UPDATE session SET unreadCount =(SELECT COUNT(im_message.id) FROM im_message WHERE isRead = 0 AND sid = new.sid)  WHERE session.sessionId = new.sid; END; CREATE TRIGGER im_update_thread_on_update AFTER  UPDATE ON im_message BEGIN delete from session WHERE session.sessionId=old.sid; insert into session(sessionId,dateTime,type,text,state) values (old.sid,old.createdTime,old.msgType,old.text,old.state); UPDATE session SET sumCount = (SELECT COUNT(im_message.id) FROM im_message LEFT JOIN session ON session.sessionId = sid WHERE sid = old.sid)   WHERE session.sessionId = old.sid; UPDATE session SET unreadCount =(SELECT COUNT(im_message.id) FROM im_message WHERE isRead = 0 AND sid = old.sid)  WHERE session.sessionId = old.sid; END; CREATE TRIGGER IF NOT EXISTS thread_update_im_on_delete AFTER DELETE ON session BEGIN DELETE FROM im_message WHERE sid = old.ID;    END;";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, createTrigger, NULL, NULL, &errmsg);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        free(errmsg);
    }
    if (SQLITE_OK!=flag) {
        NSLog(@"ERROR: Failed to createTrigger Thread!");
    }
    
    if (SQLITE_OK==flag) {
        return YES;
    }
    else return NO;
}

- (BOOL)runSql:(NSString*)sql
{
    @try {
        char * errmsg;
        int flag = 0;
        BOOL returnFlag = YES;
        const char * cSql = [sql UTF8String];
        flag = sqlite3_exec(shareDB, cSql, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flag) {
            sqlite3_free(errmsg);
            NSLog(@"ERROR: Failed to %@",sql);
            returnFlag = FALSE;
        }
        
        return returnFlag;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (NSMutableArray *)loadAllSessions
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select sessionId , dateTime , type , text , unreadCount, sumCount from session order by dateTime desc"] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];
        
        NSMutableArray * sessionArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            ECSession* session = [[ECSession alloc] init];
            int columnIndex = 0;
            session.sessionId = [stmt getString:columnIndex]; columnIndex++;
            session.dateTime = [stmt getInt64:columnIndex]; columnIndex++;
            session.type = [stmt getInt32:columnIndex]; columnIndex++;
            session.text = [stmt getString:columnIndex]; columnIndex++;
            session.unreadCount = [stmt getInt32:columnIndex]; columnIndex++;
            session.sumCount = [stmt getInt32:columnIndex]; columnIndex++;
            [sessionArray addObject:session];
            [session release];
        }
        [stmt reset]; 
        return [sessionArray autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

-(NSString*)getDateTime:(long long) data
{
    return [NSString stringWithFormat:@"%lld",data];
}

-(BOOL)getGroupFlag:(NSString *)msgid
{
    if ([[msgid substringToIndex:1] isEqualToString:@"g"])
    {
        return YES;
    }
    else
        return NO;
}

//搜索文本聊天记录
-(NSArray*)searchTextLike:(NSString*)text
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select msgid,sender,receiver, createdTime , userData ,SID,state,type,text,localPath,URL,serverTime,dstate from im_message where msgType = 1  and text like \"%%%@\%%\"  order by createdTime desc",text] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];
        
        NSMutableArray * msgArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            ECMessage* msg = [[ECMessage alloc] init];
            int columnIndex = 0;
            msg.messageId = [stmt getString:columnIndex]; columnIndex++;
            msg.from = [stmt getString:columnIndex]; columnIndex++;
            msg.to = [stmt getString:columnIndex]; columnIndex++;
            msg.timestamp = [self getDateTime:[stmt getInt64:columnIndex]]; columnIndex++;
            msg.userData = [stmt getString:columnIndex]; columnIndex++;
            msg.sessionId = [stmt getString:columnIndex]; columnIndex++;
            msg.isGroup = [self getGroupFlag:msg.messageId];
            msg.messageState = (ECMessageState)[stmt getInt32:columnIndex];columnIndex++;
            MessageBodyType msgType = (MessageBodyType)[stmt getInt32:columnIndex];columnIndex++;
            msg.messageBody = (ECMessageBody*)[self getMessageBodyWithStmt:stmt andType:msgType];
            [msgArray addObject:msg];
            [msg release];
        }
        [stmt reset];
        return [msgArray autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

-(long long)getDateInt:(NSString*) date
{
    return [date longLongValue];
}

-(NSString*)getMessageMediaType:(NSString*)displayName{
    if ([displayName hasSuffix:@".amr"])
    {
        return @"[语音]";
    }
    else if ([displayName hasSuffix:@".jpg"] || [displayName hasSuffix:@".png"])
    {
        return @"[图片]";
    }
#ifdef Support_Video_Send
    else if ([displayName hasSuffix:@".mp4"])
    {
        return @"[视频]";
    }
#endif
    else{
        return @"[文件]";
    }
}

-(int)setStmt:(Statement *) stmt andMediaMsgBody:(ECMessageBody*) msgBody andIndex:(int) index
{
    if ([msgBody isKindOfClass:[ECTextMessageBody class]])
    {
        [stmt bindInt32:MessageBodyType_Text forIndex:index]; index++;
        ECTextMessageBody * msg = (ECTextMessageBody*) msgBody;
        [stmt bindString:msg.text forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
    }
    else if ([msgBody isKindOfClass:[ECMediaMessageBody class]])
    {
        [stmt bindInt32:MessageBodyType_Media forIndex:index]; index++;
        ECMediaMessageBody * msg = (ECMediaMessageBody*) msgBody;
        
        NSString *file = @"[文件]";
        if (msg.localPath.length > 0) {
            file = [self getMessageMediaType:msg.localPath];
            
        }else if(msg.remotePath.length > 0){
            file = [self getMessageMediaType:msg.remotePath];
        }
        
        [stmt bindString:file forIndex:index]; index++;
        [stmt bindString:msg.localPath forIndex:index]; index++;
        [stmt bindString:msg.remotePath forIndex:index]; index++;
        [stmt bindString:msg.serverTime forIndex:index]; index++;
        [stmt bindString:msg.thumbnailRemotePath forIndex:index]; index++;
        [stmt bindString:msg.displayName forIndex:index];index++;
    }
    else if ([msgBody isKindOfClass:[ECChunkMessageBody class]])
    {
        [stmt bindInt32:MessageBodyType_ChunkVoice forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        ECChunkMessageBody * msg = (ECChunkMessageBody*) msgBody;
        [stmt bindString:msg.localPath forIndex:index]; index++;
        [stmt bindString:msg.remotePath forIndex:index]; index++;
        [stmt bindString:msg.serverTime forIndex:index]; index++;
    }
    return index;
}

//增加单条消息
-(BOOL)addMessage:(ECMessage*)message
{
    
    @try
    {
        const char * add = "insert into im_message(SID,msgid,sender, receiver,createdTime,userData,isRead,state,msgType, text, localPath, URL, serverTime,remark) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        Statement * stmt = [DBConnection statementWithQuery:add];

        int index = 1;
        [stmt bindString:message.sessionId forIndex:index]; index++;
        [stmt bindString:message.messageId forIndex:index]; index++;
        [stmt bindString:message.from forIndex:index]; index++;
        [stmt bindString:message.to forIndex:index]; index++;
        [stmt bindInt64:[self getDateInt:message.timestamp] forIndex:index]; index++;
        [stmt bindString:message.userData forIndex:index]; index++;
        [stmt bindInt32:message.isRead forIndex:index]; index++;
        [stmt bindInt32:message.messageState forIndex:index]; index++;
        index = [self setStmt:stmt andMediaMsgBody:message.messageBody andIndex:index];
        int ret = [stmt step];
        
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new message into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)isMessageExistOfMsgid:(NSString*)msgid
{
    BOOL isExist = NO;
    @try
    {
        const char * sqlString = [[NSString stringWithFormat:@"select count(*) from im_message where msgid = ?"] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:sqlString];
        [stmt bindString:msgid forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            NSInteger count = [stmt getInt32:0];
            if (count > 0)
            {
                isExist = YES;
            }
        }
        [stmt reset];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
        return isExist;
    }
}

//增加多条消息
-(NSInteger)addMessages:(NSArray*)messages
{
    int i = 0;
    for (ECMessage *msg in messages)
    {
        if([self addMessage:msg])
            i++;
    }
    return i;
}

//删除单条消息
-(BOOL)deleteMessage:(NSString*)msgId
{
    return [self runSql:[NSString stringWithFormat: @"delete from im_message where msgid = '%@'",msgId]];
}

//删除多条消息
-(NSInteger)deleteMessages:(NSArray*)messages
{
    int count = 0;
    if ([messages count]<=0)
    {
        return count;
    }
    for (NSString* msgid in messages)
    {
        if ([self deleteMessage: msgid])
        {
            count++;
        }
    }
    return count;
}

//删除某个会话的所有消息
-(NSInteger)deleteMessageOfSession:(NSString*)sessionId
{
      return [self runSql:[NSString stringWithFormat:@"delete from im_message where SID = '%@'",sessionId]];
}

- (BOOL)deleteWithTable:(NSString*)table
{
    return [self runSql:[NSString stringWithFormat:@"delete from %@",table]];
}

- (BOOL)deleteAllMessage
{
    return [self deleteWithTable:@"im_message"];
}

- (BOOL)deleteAllSession
{
    return [self deleteWithTable:@"session"];
}

- (BOOL)deleteAllGroupNotice
{
    return [self deleteWithTable:@"im_groupnotice"];
}

//清除表数据
-(NSInteger)clearMessageTable
{
    [self deleteAllMessage];
    [self deleteAllSession];
    [self deleteAllGroupNotice];
    return 0;
}

- (int)getCountWithSql:(NSString*)sql
{
    @try {
        int count = 0;
        Statement * stmt = [DBConnection statementWithQuery:[sql UTF8String]];

        [stmt bindInt32:EReadState_Unread forIndex:1];
        if (SQLITE_ROW == [stmt step])
        {
            count = [stmt getInt32:0];
        }
        [stmt reset];
        
        return count;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally
    {
    
    }
    return 0;
}


//获取表中所有未读消息数
-(NSInteger)getUnreadMessageCount
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_message where isRead = 0 and (localPath is not null or msgType = 1) "]];
}

//获取某个会话的未读消息数
-(NSInteger)getUnreadMessageCountOfSession:(NSString*)sessionId
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_message where isRead = 0 and SID = '%@' and (localPath is not null or msgType = 1) ",sessionId]];
}

//获取表中消息数
-(NSInteger)getMessageCount
{
     return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_message where (localPath is not null or msgType = 1) "]];
}

//获取某个会话的消息数
-(NSInteger)getMessageCountOfSession:(NSString*)sessionId
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_message where SID = '%@' ",sessionId]];
}

-(NSArray*)getSomeMessagesCount:(NSInteger)count andConditions:(NSString*) conditions  OfSession:(NSString *)sessionId
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select msgid,sender,receiver, createdTime , userData ,SID, state,msgType,text,localPath,URL,serverTime,dstate,remark from (select * from im_message where %@ and SID = '%@'  order by createdTime desc limit %d) order by createdTime asc",conditions,sessionId,count] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];

        NSMutableArray * msgArray = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            ECMessage* msg = [[ECMessage alloc] init];
            int columnIndex = 0;
            msg.messageId = [stmt getString:columnIndex]; columnIndex++;
            msg.from = [stmt getString:columnIndex]; columnIndex++;
            msg.to = [stmt getString:columnIndex]; columnIndex++;
            msg.timestamp = [self getDateTime:[stmt getInt64:columnIndex]]; columnIndex++;
            msg.userData = [stmt getString:columnIndex]; columnIndex++;
            msg.sessionId = [stmt getString:columnIndex]; columnIndex++;
            msg.isGroup = [self getGroupFlag:msg.messageId];
            msg.messageState = (ECMessageState)[stmt getInt32:columnIndex];columnIndex++;
            MessageBodyType msgType = (MessageBodyType)[stmt getInt32:columnIndex];columnIndex++;
            msg.messageBody = (ECMessageBody*)[self getMessageBodyWithStmt:stmt andType:msgType];
            [msgArray addObject:msg];
            [msg release];
        }
        [stmt reset];
        return [msgArray autorelease];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}
//获取会话的某个时间点之前的count条消息
-(NSArray*)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId beforeTime:(long long)timesamp
{
    return [self getSomeMessagesCount:count andConditions:[NSString stringWithFormat:@"createdTime <= %lld ",timesamp] OfSession:sessionId];
}

//获取会话的某个时间点之后的count条消息
-(NSArray*)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId afterTime:(long long)timesamp
{
    return [self getSomeMessagesCount:count andConditions:[NSString stringWithFormat:@"createdTime >= %lld ",timesamp] OfSession:sessionId];
}


-(id)getMessageBodyWithStmt:(Statement*)stmt andType:(MessageBodyType)type
{
    if (type == MessageBodyType_Text)
    {
        ECTextMessageBody* messageBody = [[[ECTextMessageBody alloc] initWithText:[stmt getString:8]] autorelease];
        messageBody.serverTime = [stmt getString:11];
        return messageBody;
    }
    else if(type == MessageBodyType_Media)
    {
        ECMediaMessageBody * messageBody = [[[ECMediaMessageBody alloc] initWithFile:[stmt getString:9] displayName:@""] autorelease];
        messageBody.remotePath = [stmt getString:10];
        messageBody.serverTime = [stmt getString:11];
        messageBody.mediaDownloadStatus = (ECMediaDownloadStatus)[stmt getInt32:12];
        messageBody.thumbnailRemotePath = [stmt getString:13];
        return messageBody;
    }
    else if(type == MessageBodyType_ChunkVoice)
    {
        ECChunkMessageBody* messageBody = [[[ECChunkMessageBody alloc] initWithFile:[stmt getString:9] displayName:@""] autorelease];
        messageBody.remotePath = [stmt getString:10];
        messageBody.serverTime = [stmt getString:11];
        return messageBody;
    }
    return nil;
}
//获取某会话最新的消息
-(ECMessage*)getLatestMessageOfSession:(NSString*)sessionId
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select msgid,sender,receiver, createdTime , userData ,SID,state,type,text,localPath,URL,serverTime,dstate from im_message where SID = '%@' order by createdTime desc limit 1",sessionId] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];

        ECMessage* msg = [[[ECMessage alloc] init] autorelease];
        while (SQLITE_ROW==[stmt step])
        {
            int columnIndex = 0;
            msg.messageId = [stmt getString:columnIndex]; columnIndex++;
            msg.from = [stmt getString:columnIndex]; columnIndex++;
            msg.to = [stmt getString:columnIndex]; columnIndex++;
            msg.timestamp = [self getDateTime:[stmt getInt64:columnIndex]]; columnIndex++;
            msg.userData = [stmt getString:columnIndex]; columnIndex++;
            msg.sessionId = [stmt getString:columnIndex]; columnIndex++;
            msg.isGroup = [self getGroupFlag:msg.messageId];
            msg.messageState = (ECMessageState)[stmt getInt32:columnIndex];columnIndex++;
            MessageBodyType msgType = (MessageBodyType)[stmt getInt32:columnIndex];columnIndex++;
            msg.messageBody = (ECMessageBody*)[self getMessageBodyWithStmt:stmt andType:msgType];
        }
        [stmt reset];
        return msg;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

//设置会话的所有消息已读
-(NSInteger)markMessagesAsReadOfSession:(NSString*)sessionId
{
   return [self runSql:[NSString stringWithFormat:@"update im_message set isRead = 1 where SID = '%@' ",sessionId]];
}

//修改单条消息的下载路径
-(BOOL)updateMessageLocalPath:(NSString*)msgId withPath:(NSString*)path
{
    return [self runSql:[NSString stringWithFormat:@"update im_message set localPath='%@' where msgid = '%@' ",path, msgId]];
}

//设置某条消息的阅读状态
-(BOOL)markMessage:(NSString*)msgId asRead:(BOOL)isRead
{
    return [self runSql:[NSString stringWithFormat:@"update im_message set isRead = %d where msgid = '%@' ",isRead, msgId]];
}

//更新某消息的状态
-(BOOL)updateState:(ECMessageState)state ofMessageId:(NSString*)msgId
{
    return [self runSql:[NSString stringWithFormat:@"update im_message set state = %d where msgid = '%@' ",state, msgId]];
}

//更新某消息的下载状态
-(BOOL)updateDownloadState:(ECMediaDownloadStatus)state ofMessageId:(NSString*)msgId
{
    return [self runSql:[NSString stringWithFormat:@"update im_message set dstate = %d where msgid = '%@' ",state, msgId]];
}

//重发，更新某消息的消息id
-(BOOL)updateMessageId:(NSString*)msdNewId ofMessageId:(NSString*)msgOldId
{
    return [self runSql:[NSString stringWithFormat:@"update im_message set msgid='%@' where msgid='%@' ", msdNewId, msgOldId]];
}

#pragma mark 群组消息操作API

-(int)setStmt:(Statement *) stmt andGroupMsg:(ECGroupNoticeMessage*) message andIndex:(int) index
{
    if (message.messageType == ECGroupMessageType_Invite)
    {
        ECInviterMsg * msg = (ECInviterMsg*) message;
        [stmt bindString:msg.admin forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++; index++;
        [stmt bindString:msg.declared forIndex:index]; index++;
        [stmt bindInt32:msg.confirm forIndex:index]; index++;
    }
    else if (message.messageType == ECGroupMessageType_Propose)
    {
        ECProposerMsg * msg = (ECProposerMsg*) message;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:msg.proposer forIndex:index]; index++;
        [stmt bindString:msg.declared forIndex:index]; index++;
        [stmt bindInt32:0 forIndex:index]; index++; index++;
    }
    else if (message.messageType == ECGroupMessageType_Join)
    {
        ECJoinGroupMsg * msg = (ECJoinGroupMsg*) message;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:msg.member forIndex:index]; index++;
        [stmt bindString:msg.declared forIndex:index]; index++;
        [stmt bindInt32:0 forIndex:index]; index++;
    }
    else if (message.messageType == ECGroupMessageType_Quit)
    {
        ECQuitGroupMsg * msg = (ECQuitGroupMsg*) message;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:msg.member forIndex:index];index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindInt32:0 forIndex:index]; index++;
    }
    else if (message.messageType == ECGroupMessageType_RemoveMember)
    {
        ECRemoveMemberMsg * msg = (ECRemoveMemberMsg*) message;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindString:msg.member forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindInt32:0 forIndex:index]; index++;
    }
    else if (message.messageType == ECGroupMessageType_ReplyInvite)
    {
        ECReplyJoinGroupMsg * msg = (ECReplyJoinGroupMsg*) message;
        [stmt bindString:msg.admin forIndex:index]; index++;
        [stmt bindString:msg.member forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindInt32:msg.confirm forIndex:index]; index++;
    }
    else if (message.messageType == ECGroupMessageType_ReplyJoin)
    {
        ECReplyJoinGroupMsg * msg = (ECReplyJoinGroupMsg*) message;
        [stmt bindString:msg.admin forIndex:index]; index++;
        [stmt bindString:msg.member forIndex:index]; index++;
        [stmt bindString:@"" forIndex:index]; index++;
        [stmt bindInt32:msg.confirm forIndex:index]; index++;
    }
    return index;
}

//增加一条消息
-(BOOL)addGroupMessage:(ECGroupNoticeMessage*)message
{
    @try
    {
        const char * add = "insert into im_groupnotice(groupId,type,dateCreated,isRead,admin,member,declared,confirm) values (?,?,?,?,?,?,?,?)";
        Statement * stmt = [DBConnection statementWithQuery:add];
        
        int index = 1;
        [stmt bindString:message.groupId forIndex:index]; index++;
        [stmt bindInt32:message.messageType forIndex:index]; index++;
        [stmt bindInt64:[self getDateInt:message.dateCreated] forIndex:index]; index++;
        [stmt bindInt32:message.isRead forIndex:index]; index++;
        index = [self setStmt:stmt andGroupMsg:message andIndex:index];
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new im_groupnotice into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}
//增加一条消息
-(BOOL)addGroupID:(ECGroup*)group
{
    @try
    {
        const char * add = "insert or ignore into im_groupinfo(groupId,groupname) values (?,?)";
        Statement * stmt = [DBConnection statementWithQuery:add];
        
        int index = 1;
        [stmt bindString:group.groupId forIndex:index]; index++;
        [stmt bindString:group.name forIndex:index];
        
        int ret = [stmt step];
        if (SQLITE_DONE!=ret) {
            NSLog(@"ERROR: Failed to add new im_groupnotice into im_message!ret=%d,%s",ret,__func__);
            [stmt reset];
            return NO;
        }
        [stmt reset];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

//增加多条消息
-(NSInteger)addGroupMessages:(NSArray*)messages
{
    int i = 0;
    for (ECGroupNoticeMessage* groupMsg in messages)
    {
        if ([self addGroupMessage:groupMsg])
        {
            i++;
        }
    }
    return i;
}
//增加多条消息
-(NSInteger)addGroupIDs:(NSArray*)messages
{
    int i = 0;
    for (ECGroup* groupMsg in messages)
    {
        if ([self addGroupID:groupMsg])
        {
            i++;
        }
    }
    return i;
}

-(NSString *)getGroupNameOfId:(NSString *)groupId
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select groupname from im_groupinfo where groupid = '%@'",groupId] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];
        NSString * stringname = nil;
        while (SQLITE_ROW==[stmt step])
        {
           stringname = [stmt getString:0];
            
        }
        [stmt reset];
        return stringname;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;

}
//删除关于某群组的所有消息
-(NSInteger)deleteGroupMessagesOfGroup:(NSString*)groupId
{
    return [self runSql:[NSString stringWithFormat:@"delete from im_groupnotice where groupId = '%@'",groupId]];
}

//清空表
-(NSInteger)clearGroupMessageTable
{
    return [self deleteAllGroupNotice];
}

//获取表中所有未读消息数
-(NSInteger)getUnreadGroupMessageCount
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_groupnotice where isRead =0 "]];
}

//获取确定群组的未读消息数
-(NSInteger)getUnreadGroupMessageCountOfGroup:(NSString*)groupId
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_groupnotice where isRead =0 and groupId = '%@'",groupId]];
}

//获取表中消息数
-(NSInteger)getAllGroupMessageCount
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_groupnotice"]];
}

//获取表中确定群组消息数
-(NSInteger)getAllGroupMessageCountOfGroup:(NSString*)groupId
{
    return [self getCountWithSql:[NSString stringWithFormat:@"select count(*) from im_groupnotice where groupId = '%@'",groupId]];
}

//获取群组中某个时间点之前的count条数据
-(NSArray*)getSomeGroupMessagesCount:(NSInteger)count OfGroup:(NSString*)group beforeTime:(long long)timesamp
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select groupId,type,dateCreated,isRead,admin, member,declared, confirm from im_groupnotice where groupId = '%@' and dateCreated <= %lld order by dateCreated desc limit %d",group,timesamp,count] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];
        
        NSMutableArray* groupMsgArr = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            [groupMsgArr addObject:[self getGroupMsgWithStmt:stmt]];
        }
        [stmt reset];
        return [NSArray arrayWithArray:groupMsgArr];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

//获取群组中某个时间点之前的count条数据
-(NSArray*)getSomeGroupMessagesCount:(NSInteger)count beforeTime:(long long)timesamp
{
    @try
    {
        const char * getMsgSql =  [[NSString stringWithFormat:@"select groupId,type,dateCreated,isRead,admin,member,declared,confirm from im_groupnotice where dateCreated <= %lld order by dateCreated desc limit %d",timesamp,count] UTF8String];
        Statement * stmt = [DBConnection statementWithQuery:getMsgSql];
        
        NSMutableArray* groupMsgArr = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==[stmt step])
        {
            [groupMsgArr addObject:[self getGroupMsgWithStmt:stmt]];
        }
        [stmt reset];
        return [NSArray arrayWithArray:groupMsgArr];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception name=%@",exception.name);
        NSLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

-(id)getGroupMsgWithStmt:(Statement*)stmt
{
    int messageType = [stmt getInt32:1];
    if (messageType == ECGroupMessageType_Dissmiss)
    {
        ECDismissGroupMsg * msg = [[ECDismissGroupMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_Invite)
    {
        ECInviterMsg * msg = [[ECInviterMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.admin = [stmt getString:4];
        msg.declared = [stmt getString:6];
        msg.confirm = [stmt getInt32:7];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_Propose)
    {
        ECProposerMsg * msg = [[ECProposerMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.declared = [stmt getString:6];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_Join)
    {
        ECJoinGroupMsg * msg = [[ECJoinGroupMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.member = [stmt getString:5];
        msg.declared = [stmt getString:6];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_Quit)
    {
        ECQuitGroupMsg * msg = [[ECQuitGroupMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.member = [stmt getString:5];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_RemoveMember)
    {
        ECRemoveMemberMsg * msg = [[ECRemoveMemberMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.member = [stmt getString:5];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_ReplyInvite)
    {
        ECReplyInviteGroupMsg * msg = [[ECReplyInviteGroupMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.admin = [stmt getString:4];
        msg.member = [stmt getString:5];
        msg.confirm = [stmt getInt32:7];
        return [msg autorelease];
    }
    else if (messageType == ECGroupMessageType_ReplyJoin)
    {
        ECReplyJoinGroupMsg * msg = [[ECReplyJoinGroupMsg alloc] init];
        msg.groupId = [stmt getString:0];
        msg.dateCreated = [stmt getString:2];
        msg.isRead = [stmt getInt32:3];
        msg.admin = [stmt getString:4];
        msg.member = [stmt getString:5];
        msg.confirm = [stmt getInt32:7];
        return [msg autorelease];
    }
    return nil;
}

//标记某群组中所有消息已读
-(NSInteger)markGroupMessagesAsReadOfGroup:(NSString*)groupId
{
    return [self runSql:[NSString stringWithFormat:@"update im_groupnotice set isRead = 1 where groupId = '%@' ", groupId]];
}

//标记表中所有消息已读
-(NSInteger)markGroupMessagesAsRead
{
    return [self runSql:[NSString stringWithFormat:@"update im_groupnotice set isRead = 1"]];
}

//+ (NSDictionary *)properties_aps:(id)obj
//{
//    NSMutableDictionary *props = [NSMutableDictionary dictionary];
//    unsigned int outCount, i;
//    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
//    for (i = 0; i<outCount; i++)
//    {
//        objc_property_t property = properties[i];
//        const char* char_f =property_getName(property);
//        NSString *propertyName = [NSString stringWithUTF8String:char_f];
//        id propertyValue = [obj valueForKey:(NSString *)propertyName];
//        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
//    }
//    free(properties);
//    return props;
//}

@end
