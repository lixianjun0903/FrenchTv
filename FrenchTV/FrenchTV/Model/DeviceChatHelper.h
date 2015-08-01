//
//  DeviceChatHelper.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/15.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "ECMessage.h"
#import "ECError.h"

#define KNOTIFICATION_SendMessageCompletion       @"KNOTIFICATION_SendMessageCompletion"
#define KNOTIFICATION_DownloadMessageCompletion   @"KNOTIFICATION_DownloadMessageCompletion"

#define KErrorKey   @"kerrorkey"
#define KMessageKey @"kmessagekey"
@class ECMediaMessageBody;
@interface DeviceChatHelper : NSObject

+(DeviceChatHelper*)sharedInstance;

-(ECMessage*)sendTextMessage:(NSString*)text to:(NSString*)to;
-(ECMessage*)sendMediaMessage:(ECMediaMessageBody*)mediaBody to:(NSString*)to;

-(ECMessage*)resendMessage:(ECMessage*)message;

-(void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion;;

@end
