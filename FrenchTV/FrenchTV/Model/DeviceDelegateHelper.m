//
//  DeviceDelegateHelper.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DeviceDelegateHelper.h"
#import "EmojiConvertor.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "DemoGlobalClass.h"
#import "DeviceDBHelper.h"

@implementation DeviceDelegateHelper
{
    SystemSoundID receiveSound;
    UIAlertView *_alertView;
}

+(DeviceDelegateHelper*)sharedInstance
{
    static DeviceDelegateHelper *devicedelegatehelper;
    static dispatch_once_t devicedelegatehelperonce;
    dispatch_once(&devicedelegatehelperonce, ^{
        devicedelegatehelper = [[DeviceDelegateHelper alloc] init];
    });
    return devicedelegatehelper;
}

-(instancetype)init{
    if (self = [super init]) {
//        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"receive_msg"
//                                                              ofType:@"caf"];
//        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
//        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
//                                                        &receiveSound);
//        if (err != kAudioServicesNoError)
//            NSLog(@"Could not load %@, error code: %d", soundURL, (int)err);
    }
    return self;
}

-(void)playRecMsgSound{
    
    NSNumber *isPlay = [[NSUserDefaults standardUserDefaults] objectForKey:@"message_sound"];
    if (isPlay==nil || isPlay.boolValue) {
        //播放声音
        AudioServicesPlaySystemSound(receiveSound);
    }
    
    isPlay = [[NSUserDefaults standardUserDefaults] objectForKey:@"message_shake"];
    //震动
    if (isPlay==nil || isPlay.boolValue)
         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


/**
 @brief 网络改变后调用的代理方法
 @param status 网络状态值
 */
- (void)onReachbilityChanged:(ECNetworkType)status
{
    if (status == ECNetworkType_NONE) {
        if (_alertView) {
            [_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
        }
        
        _alertView = [[UIAlertView alloc]initWithTitle:nil message:@"无网络,请确认网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [_alertView show];
    }
    
    [DemoGlobalClass sharedInstance].netType = status;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onNetworkChanged object:@(status)];
}
/**
 @brief 登录状态接口
 @discussion 监听与服务器的登录状态
 @param error 连接的状态
 */
-(void)onConnected:(ECError *)error
{
    [DemoGlobalClass sharedInstance].isLogin = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];

    if (error.errorCode == ECErrorType_KickedOff) {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_Connacts];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_LoginUser];
        
        if (_alertView) {
            [_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
        }
        _alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"账号已在其它地方登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [_alertView show];
    }
    else if (error.errorCode == ECErrorType_NoError)
    {
        [DemoGlobalClass sharedInstance].isLogin = YES;
    }
    else
    {
        if (_alertView) {
            [_alertView dismissWithClickedButtonIndex:_alertView.cancelButtonIndex animated:NO];
        }
        _alertView = [[UIAlertView alloc]initWithTitle:@"登录失败"
                                                        message:[NSString stringWithFormat:@"错误码:%d",error.errorCode]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [_alertView show];
    }
    
    NSLog(@"\r==========\ronConnected errorcode=%d\r============", error.errorCode);
    
}

/**
 @brief 注销状态接口
 @discussion 监听与服务器注销结果
 @param error 注销结果
 */
-(void)onDisconnect:(ECError *)error
{
    [DemoGlobalClass sharedInstance].isLogin = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onDisconnected object:error];
}

/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveMessage:(ECMessage*)message{
    
    
    
    if ([[DeviceDBHelper sharedInstance].msgDBAccess isMessageExistOfMsgid:message.messageId]) {
        return;
    }
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        if ([UIDevice currentDevice].systemVersion.floatValue > 6)
        {
            ECTextMessageBody * textmsg = (ECTextMessageBody *)message.messageBody;
            textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
        }
        
    }
#warning 时间全部转换成本地时间
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[DeviceDBHelper sharedInstance].msgDBAccess addMessage:message];
    
    [self playRecMsgSound];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:message];
    
    if(message.messageBody.messageBodyType == MessageBodyType_Media){
        ECMediaMessageBody *body = (ECMediaMessageBody*)message.messageBody;
        NSRange range = [body.remotePath rangeOfString:@"?fileName="];
        body.displayName = [body.remotePath substringFromIndex:range.location+range.length];
        [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:nil];
    }
}


/**
 @brief 客户端录音振幅代理函数
 @param amplitude 录音振幅
 */
-(void)onRecordingAmplitude:(double) amplitude{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onRecordingAmplitude object:@(amplitude)];
}

/**
 @brief 接收群组相关消息
 @discussion 参数要根据消息的类型，转成相关的消息类；
 解散群组、收到邀请、申请加入、退出群组、有人加入、移除成员等消息
 @param groupMsg 群组消息
 */
-(void)onReceiveGroupNoticeMessage:(ECGroupNoticeMessage *)groupMsg{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    
#warning 时间全部转换成本地时间
    groupMsg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    [[DeviceDBHelper sharedInstance].msgDBAccess addGroupMessage:groupMsg];
    if (groupMsg.messageType ==ECGroupMessageType_Dissmiss) {
        [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:groupMsg.groupId];
    }
    else if (groupMsg.messageType == ECGroupMessageType_RemoveMember)
    {
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)groupMsg;
        if ([message.member isEqualToString:[DemoGlobalClass sharedInstance].loginInfoDic[voipKey]]) {
            [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:groupMsg.groupId];
        }
    }
    [self playRecMsgSound];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceivedGroupNotice object:groupMsg];
    
}
@end
