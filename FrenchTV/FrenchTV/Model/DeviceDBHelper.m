//
//  DeviceDBHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceDBHelper.h"
#import "ECSession.h"

@implementation DeviceDBHelper

+(DeviceDBHelper*)sharedInstance{
    
    static dispatch_once_t DeviceDBHelperonce;
    static DeviceDBHelper * DeviceDBHelperstatic;
    dispatch_once(&DeviceDBHelperonce, ^{
        DeviceDBHelperstatic = [[DeviceDBHelper alloc] init];
    });
    return DeviceDBHelperstatic;
}

-(void)openDataBasePath:(NSString*)voip
{
    self.msgDBAccess = [[IMMsgDBAccess alloc] initWithName:voip];
}

-(NSArray*)getLatestHundredMessageOfSessionId:(NSString*)sessionId{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 以本地时间获取之前数据和排序
    return [self.msgDBAccess getSomeMessagesCount:100 OfSession:sessionId beforeTime:(long long)tmp];
}

//删除会话的数据
-(void)deleteAllMessageOfSession:(NSString*)sessionId{
    [self.msgDBAccess deleteMessageOfSession:sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:sessionId];
}

-(NSArray*)getLatestHundredGroupNotice{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 以本地时间获取之前数据和排序
    return [self.msgDBAccess getSomeGroupMessagesCount:100 beforeTime:(long long)tmp];
}


-(ECGroupNoticeMessage*)getLatestGroupMessage{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 以本地时间戳获取消息
    NSArray *messageArray = [self.msgDBAccess getSomeGroupMessagesCount:1 beforeTime:(long long)tmp];
    if (messageArray && messageArray.count > 0) {
        return [messageArray objectAtIndex:0];
    }
    return nil;
}

-(NSArray*)getMyCustomSession{
    NSMutableArray *sessionArr = [NSMutableArray arrayWithArray:[self.msgDBAccess loadAllSessions]];
    
    ECGroupNoticeMessage * groupMessage = [self getLatestGroupMessage];
    if (groupMessage ) {
        ECSession *session = [[ECSession alloc] init];
        session.sessionId = @"群组消息通知";
        session.dateTime = [groupMessage.dateCreated longLongValue];
        session.type = 100;
        session.unreadCount = [self.msgDBAccess getUnreadGroupMessageCount];
        switch (groupMessage.messageType) {
            case ECGroupMessageType_Dissmiss:
                session.text = @"有群组解散";
                break;
                
            case ECGroupMessageType_Invite:
                session.text = @"有人邀请加入群组";
                break;
                
            case ECGroupMessageType_Propose:
                session.text = @"有人申请加入群组";
                break;
                
            case ECGroupMessageType_Join:
                session.text = @"有人加入群组";
                break;
                
            case ECGroupMessageType_Quit:
                session.text = @"有人退出群组";
                break;
                
            case ECGroupMessageType_RemoveMember:
                session.text = @"有人被踢出群组";
                break;
                
            case ECGroupMessageType_ReplyInvite:
                session.text = @"有回复邀请";
                break;
                
            case ECGroupMessageType_ReplyJoin:
                session.text = @"有回复申请";
                break;
                
            default:
                break;
        }
        [sessionArr addObject:session];
    }
    
    return  [sessionArr sortedArrayUsingComparator:
                                     ^(ECSession *obj1, ECSession* obj2){
                                         if(obj1.dateTime > obj2.dateTime) {
                                             return(NSComparisonResult)NSOrderedAscending;
                                         }else {
                                             return(NSComparisonResult)NSOrderedDescending;
                                         }
                                     }];
}
@end
