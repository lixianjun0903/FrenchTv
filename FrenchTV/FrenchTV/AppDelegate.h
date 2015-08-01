//
//  AppDelegate.h
//  FrenchTV
//
//  Created by gaobo on 15/2/4.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "MainTabBarController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign)int unReadNum;

+(AppDelegate*)instance;
+(UINavigationController *)getNav;
+(MainTabBarController *)getTabbar;

//广播
-(void)playAudio:(NSString *)strUrl;
-(void)audioPause;

@end

