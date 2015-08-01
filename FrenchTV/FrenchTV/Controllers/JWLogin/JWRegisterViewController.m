//
//  JWLoginViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/2/4.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "JWRegisterViewController.h"
#import "MBProgressHUD+Show.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonTools.h"
#import "DemoGlobalClass.h"
#import "GDataXMLParser.h"
#import "JW_HomeViewController.h"
#import "ECLoginInfo.h"
#import "ECDevice.h"
#import "AppDelegate.h"
#import "AccountRequest.h"
#import "DeviceDelegateHelper.h"

@interface JWRegisterViewController ()

@end

@implementation JWRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createUI];
}

-(void)createUI
{
    self.BGView.layer.cornerRadius = 5;
    self.BGView.layer.borderWidth = 1;
    self.BGView.layer.borderColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1].CGColor;
    self.BGView.layer.masksToBounds = YES;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.massageTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)regiestClick:(UIButton *)sender {
    if(![_massageTextField.text isEqualToString:@""])
    {

        if(![_passwordTextField.text isEqualToString:@""])
        {
            [AccountRequest RegisterRequestWithUserName:_massageTextField.text PassWord:_passwordTextField.text withAccountName:_nameTextField.text succ:^(NSDictionary * data) {
                if([data[@"status"] integerValue] == 0)
                {
                    [MBProgressHUD creatembHub:@"注册成功"];
                    [self endKeyBoard];
                    [self LoginSuccess:nil];
                    
                    
                    [[NSUserDefaults standardUserDefaults]setObject:_nameTextField.text forKey:@"userName"];
                    
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }else
                {
                    [MBProgressHUD creatembHub:data[@"message"]];
                }
                
            }];
            
            
            
        }

    }
}

-(void)endKeyBoard
{
    [self.nameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.massageTextField resignFirstResponder];
}


-(void)LoginSuccess:(NSDictionary *)data
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在登录";
    hud.removeFromSuperViewOnHide = YES;

    
    
    
    
    [AccountRequest LoginRequestWithUserName:_massageTextField.text PassWord:_passwordTextField.text succ:^(NSDictionary * responseData) {
        
        if([responseData[@"status"] integerValue] == 1)
        {
            ECNoTitleAlert(responseData[@"message"]);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            return;
        }
        
        NSDictionary * data = responseData[@"data"];
        
        [[DeviceDBHelper sharedInstance] openDataBasePath:data[@"voipAccount"]];
        ECLoginInfo * loginInfo = [[ECLoginInfo alloc] initWithAccount:data[@"voipAccount"] Password:data[@"voipPassword"]];
        loginInfo.subAccount = data[@"subAccountId"];
        loginInfo.subToken = data[@"subToken"];
        [DemoGlobalClass sharedInstance].loginInfo = loginInfo;
        [DemoGlobalClass sharedInstance].userInfoDic = [data mutableCopy];
        
        if(loginInfo)
        {
            [self loginToEC:loginInfo];
        }
        

        [[NSUserDefaults standardUserDefaults] setObject:data forKey:UserDefault_LoginUser];
        [[NSUserDefaults standardUserDefaults] setObject:_massageTextField.text forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"PassWord"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }];
    
    
    
}

-(void)loginToEC:(ECLoginInfo *)info
{
    [[ECDevice sharedInstance] login:info completion:^(ECError *error) {
        if (error.errorCode == ECErrorType_NoError) {
            
            [MBProgressHUD creatembHub:@"登陆成功"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:nil];
            
        }else
        {
            ECNoTitleAlert(@"登陆失败");
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
}

@end
