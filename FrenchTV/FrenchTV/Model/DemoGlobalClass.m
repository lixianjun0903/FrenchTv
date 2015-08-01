//
//  DemoGlobalClass.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DemoGlobalClass.h"
#import "DeviceDBHelper.h"
#import "ECDevice.h"
#import <UIKit/UIKit.h>

@implementation DemoGlobalClass

+(DemoGlobalClass*)sharedInstance{
    static DemoGlobalClass *demoglobalclass;
    static dispatch_once_t demoglobalclassonce;
    dispatch_once(&demoglobalclassonce, ^{
        demoglobalclass = [[DemoGlobalClass alloc] init];
    });
    return demoglobalclass;
}

-(id)init{
    if (self = [super init]) {
        self.mainAccontDictionary = [NSMutableDictionary dictionary];
        self.subAccontsArray = [NSMutableArray array];
        self.appInfoDictionary = [NSMutableDictionary dictionary];
        self.allSessions = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSString*)getOtherNameWithVoip:(NSString*)voip{
    if (voip.length > 0) {
        for (NSMutableDictionary *accountinfo in self.subAccontsArray) {
            if ([voip isEqualToString:accountinfo[voipKey]]) {
                return accountinfo[nameKey];
            }
        }
    }
    if ([voip isEqualToString:self.loginInfoDic[voipKey]]) {
        return self.loginInfoDic[nameKey];
    }
    if ([voip hasPrefix:@"g"]) {
        NSString * name = [[DeviceDBHelper sharedInstance].msgDBAccess getGroupNameOfId:voip];
        if (name.length ==0) {
            
            //请求群组信息
            [[ECDevice sharedInstance].messageManager getGroupDetail:voip completion:^(ECError *error, ECGroup *group) {
                
                if (error.errorCode == ECErrorType_NoError) {
                    
                    [[DeviceDBHelper sharedInstance].msgDBAccess addGroupIDs:@[group]];
                    [[NSNotificationCenter defaultCenter]postNotificationName:KNotice_GetGroupName object:group.groupId];
                }
                
            }];

            return voip;
        }
        else
            return name;
    }
    return voip;
}

-(NSMutableDictionary*)getOtherDictionaryWithVoip:(NSString*)voip{
    if (voip.length > 0) {
        for (NSMutableDictionary *accountinfo in self.subAccontsArray) {
            if ([voip isEqualToString:accountinfo[voipKey]]) {
                return accountinfo;
            }
        }
        return nil;
    }
    return nil;
}

-(UIImage*)getOtherImageWithVoip:(NSString*)voip{
    if (voip.length > 0) {
        for (NSMutableDictionary *accountinfo in self.subAccontsArray) {
            if ([voip isEqualToString:accountinfo[voipKey]]) {
                return [UIImage imageNamed:accountinfo[imageKey]];
            }
        }
    }
    if ([voip isEqualToString:self.loginInfoDic[voipKey]]) {
        return [UIImage imageNamed:self.loginInfoDic[imageKey]];
    }
    if([voip hasPrefix:@"g"])
    {
        return [UIImage imageNamed:@"group_head"];
    }
    else
    {
        return [UIImage imageNamed:@"select_account_photo_3"];
    }
}
@end
