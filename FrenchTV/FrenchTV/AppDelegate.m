//
//  AppDelegate.m
//  FrenchTV
//
//  Created by gaobo on 15/2/4.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "AppDelegate.h"
#import "JWRegisterViewController.h"
#import "DeviceDelegateHelper.h"
#import "DemoGlobalClass.h"
#import "JWRegisterViewController.h"
#import "JW_HomeViewController.h"
#import "FlipSquaresNavigationController.h"
#import "CubeNavigationController.h"
#import "MainLoginViewController.h"
#import "APService.h"


@interface AppDelegate () <UITabBarControllerDelegate>
{
}

@property (strong , nonatomic) AVAudioPlayer * p;
@property MainLoginViewController * loginView;
@property UINavigationController * mainView;
@property NSMutableDictionary * loginInfo;

@end

@implementation AppDelegate


+(AppDelegate*)instance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

+(MainTabBarController *)getTabbar
{
    UINavigationController * nc = (UINavigationController *)[AppDelegate instance].window.rootViewController;
    return (MainTabBarController *)nc.topViewController;
}

+(UINavigationController *)getNav
{
    UINavigationController * nc = (UINavigationController *)[AppDelegate instance].window.rootViewController;
    return nc;
}

-(void)playAudio:(NSString*)strUrl
{
    NSError *playerError;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"forYoung" ofType:@"mp3"];
    
    self.p = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&playerError];
    self.p.numberOfLoops = -1;
    self.p.volume = 1;
    [self.p prepareToPlay];
    [self.p play];
}

-(void)audioPause
{
    [self.p pause];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    //集成UM
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navi4BG"] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont systemFontOfSize:20],UITextAttributeTextColor:[UIColor darkGrayColor]}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChanged:) name:KNOTIFICATION_onConnected object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotification:) name:@"pushNotification" object:nil];
    
    [ECDevice sharedInstance].delegate = [DeviceDelegateHelper sharedInstance];
    
    
    //检验本地是否存在用户信息
    if([self getLoginInfo])
    {
        MainTabBarController * mtbc = [[MainTabBarController alloc]init];
        mtbc.delegate = self;

        [[DeviceDBHelper sharedInstance] openDataBasePath:self.loginInfo[@"voipAccount"]];
        UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:mtbc];
//        nc.title = @"@RCI";
        self.mainView = nc;
        self.window.rootViewController = self.mainView;
        
    }else
    {
    
        self.loginView = [[MainLoginViewController alloc] init];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:self.loginView];
    
        self.window.rootViewController = nc;
    }

    
    
    [self.window makeKeyAndVisible];

    return YES;
}


-(void)createMainNav
{
    MainTabBarController * mtbc = [[MainTabBarController alloc]init];
    
    mtbc.delegate = self;
    UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:mtbc];
//    nc.title = @"@RCI";
    self.window.rootViewController = nc;
}

-(BOOL)getLoginInfo{
    
    _loginInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    
    _loginInfo = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_LoginUser];
    
    if (_loginInfo != nil && _loginInfo.count !=0) {
        
        return YES;
    }
    return NO;
}
//登录页和主页面间的切换
-(void)connectStateChanged:(NSNotification *)notification{
    ECError* error = notification.object;
    
//    UINavigationController * rootView = (UINavigationController*)self.window.rootViewController;
    
    if (error && error.errorCode == ECErrorType_NoError) {
        if(_mainView == nil)
        {
//            CATransition * caSwitch = [CATransition animation];
//            caSwitch.delegate=self;
//            caSwitch.duration=1.5;
//            caSwitch.timingFunction=UIViewAnimationCurveEaseInOut;
//            caSwitch.type=@"rippleEffect";
//            //超级动画效果 哈哈哈
//            //        [[self.navigationController.view layer]addAnimation:caSwitch forKey:@"switch"];
//            [self.window.layer addAnimation:caSwitch forKey:@"switch"];
            
            [self createMainNav];
        }else
        {
            self.window.rootViewController = self.mainView;
        }
        _loginView = nil;
        
    }
    
     if(error && error.errorCode == ECErrorType_KickedOff){
        if (_loginView == nil) {
            self.loginView = [[MainLoginViewController alloc] init];
            self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_loginView];
        }
        else{
            self.window.rootViewController = self.loginView.navigationController;
        }
        self.mainView = nil;
    }
    
    
}

-(void)createNotification:(ECMessage *)message
{
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if(version >= 7.1f)
    {
        if([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    UILocalNotification * local = [[UILocalNotification alloc] init];
    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    
    local.alertBody = @"您有一条新信息";
    
    UIApplicationState * state = [[UIApplication sharedApplication] applicationState];
//    if(state == UIApplicationStateBackground)
//    {
//        NSInteger num= (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
//        if(num == 0)
//        {
//            num = 1;
//        }
//        else
//        {
//            num++;
//        }
//        local.applicationIconBadgeNumber = num;
//            
//    }
    [[UIApplication sharedApplication]scheduleLocalNotification:local];
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState * state = application.applicationState;
    if(state == UIApplicationStateActive)
    {
        //这里表示在前台运行,在这里自定义一个类似推送的视图
        
        
    }
}


#pragma mark tabbarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    switch (tabBarController.selectedIndex) {
        case 0:
        {
            tabBarController.title = @"@RCI";
            if([AppDelegate getNav].viewControllers.count !=1)
            {
                tabBarController.navigationItem.leftBarButtonItem = nil;
            }
            
        }
            break;
        case 1:
        {
            tabBarController.title = @"@RCI";
            if([AppDelegate getNav].viewControllers.count !=1)
            {
                tabBarController.navigationItem.leftBarButtonItem = nil;
            }

        }
            break;
        case 2:
        {
            tabBarController.title = @"中文课堂";
            tabBarController.navigationItem.leftBarButtonItem = nil;

            

        }
            break;
        case 3:
        {
            tabBarController.title = @"Profil";
            tabBarController.navigationItem.leftBarButtonItem = nil;


        }
            break;
            
        default:
            break;
    }
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
