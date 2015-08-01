//
//  JWLoginViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "JWLoginViewController.h"
#import "JWRegisterViewController.h"

@interface JWLoginViewController ()

@end

@implementation JWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
}

//-(void)createNav
//{
//    UIButton * regBtn = [UIButton buttonWithType: UIButtonTypeSystem];
//    [regBtn setTitle:@"S'inscrire" forState:UIControlStateNormal];
//    regBtn.frame = CGRectMake(0, 0, 80, 20);
//    [regBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:regBtn];
//}
//
//-(void)btnClick
//{
//    [self.navigationController pushViewController:[JWRegisterViewController new] animated:YES];
//}

-(void)createUI
{
    self.BGView.layer.cornerRadius = 5;
    self.BGView.layer.borderWidth = 1;
    self.BGView.layer.borderColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1].CGColor;
    self.BGView.layer.masksToBounds = YES;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}


- (IBAction)accountLogin:(id)sender
{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在登录";
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
    hud.removeFromSuperViewOnHide = YES;
    

    [AccountRequest LoginRequestWithUserName:self.emailField.text PassWord:_passwordField.text succ:^(NSDictionary * responseData) {
        
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
        [[NSUserDefaults standardUserDefaults] setObject:_emailField.text forKey:@"UserName"];
        [[NSUserDefaults standardUserDefaults] setObject:_passwordField.text forKey:@"PassWord"];
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





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
