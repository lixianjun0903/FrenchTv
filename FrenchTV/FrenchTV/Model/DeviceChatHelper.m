//
//  DeviceChatHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceChatHelper.h"
#import "EmojiConvertor.h"
#import "ECDevice.h"
#import "DeviceDBHelper.h"
#import <UIKit/UIKit.h>
@implementation DeviceChatHelper
{
    SystemSoundID sendSound;
}

+(DeviceChatHelper*)sharedInstance{
    static dispatch_once_t DeviceChatHelperOnce;
    static DeviceChatHelper *deviceChatHelper;
    dispatch_once(&DeviceChatHelperOnce, ^{
        deviceChatHelper = [[DeviceChatHelper alloc] init];
    });
    return deviceChatHelper;
}

-(instancetype)init{
    if (self = [super init]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"sendmsgsuc"
                                                              ofType:@"caf"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                                        &sendSound);
        if (err != kAudioServicesNoError)
            NSLog(@"Could not load %@, error code: %d", soundURL, (int)err);
    }
    return self;
}

-(void)playSendMsgSound{
    
    NSNumber *isPlay = [[NSUserDefaults standardUserDefaults] objectForKey:@"message_sound"];
    if (isPlay==nil || isPlay.boolValue) {
        //播放声音
        AudioServicesPlaySystemSound(sendSound);
    }
}

-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to{
    
    if ([UIDevice currentDevice].systemVersion.floatValue > 6)
    {
        text = [[EmojiConvertor sharedInstance] convertEmojiUnicodeToSoftbank:text];
    }
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:messageBody];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];

    [[ECDevice sharedInstance].messageManager sendMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage) {
        
        if (error.errorCode == ECErrorType_NoError) {
            [self playSendMsgSound];
        }
        
        [[DeviceDBHelper sharedInstance].msgDBAccess updateState:message.messageState ofMessageId:message.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    
    if ([UIDevice currentDevice].systemVersion.floatValue > 6)
    {
        ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
        textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    }
    
    [[DeviceDBHelper sharedInstance].msgDBAccess addMessage:message];

    return message;
}

-(ECMessage*)sendMediaMessage:(ECMediaMessageBody*)mediaBody to:(NSString*)to{
    
    ECMessage *message = [[ECMessage alloc] initWithReceiver:to body:mediaBody];
    message.userData = mediaBody.displayName;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[ECDevice sharedInstance].messageManager sendMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage) {
        
        if (error.errorCode == ECErrorType_NoError) {
            [self playSendMsgSound];
        }
        
        [[DeviceDBHelper sharedInstance].msgDBAccess updateState:message.messageState ofMessageId:message.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    
    [[DeviceDBHelper sharedInstance].msgDBAccess addMessage:message];    
    
    return message;
}

-(void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion{
    
    ECMediaMessageBody *mediaBody = (ECMediaMessageBody*)message.messageBody;
    mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.displayName];
        
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:nil completion:^(ECError *error, ECMessage *message) {
        if (error.errorCode == ECErrorType_NoError) {
            [[DeviceDBHelper sharedInstance].msgDBAccess updateMessageLocalPath:message.messageId withPath:mediaBody.localPath];
        }
        else{
            mediaBody.localPath = nil;
            [[DeviceDBHelper sharedInstance].msgDBAccess updateMessageLocalPath:message.messageId withPath:@""];
        }
        
        if (completion != nil) {
            completion(error, message);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];

    }];
}

-(ECMessage*)resendMessage:(ECMessage*)message{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 入库前设置本地时间，以本地时间排序和以本地时间戳获取本地数据库缓存数据
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    NSString *oldMsgId = message.messageId;
    NSString* newMsgId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage) {
        
        if (error.errorCode == ECErrorType_NoError) {
            [self playSendMsgSound];
        }
        
        [[DeviceDBHelper sharedInstance].msgDBAccess updateState:message.messageState ofMessageId:message.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    
    //更新消息id
    [[DeviceDBHelper sharedInstance].msgDBAccess updateMessageId:newMsgId ofMessageId:oldMsgId];

    return nil;
}
@end
