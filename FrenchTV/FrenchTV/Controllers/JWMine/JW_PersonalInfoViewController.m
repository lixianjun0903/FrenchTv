//
//  JW_PersonalInfoViewController.m
//  FrenchTV
//
//  Created by mac on 15/2/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "JW_PersonalInfoViewController.h"
#import "PersonSetController.h"
#import "FeedBackViewController.h"
#import "HostMessageViewController.h"
#import "IntroduceViewController.h"
#import "FavoriteViewController.h"


@interface JW_PersonalInfoViewController ()<UIAlertViewDelegate>

@end

@implementation JW_PersonalInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = NO;
    self.userName.text = [DemoGlobalClass sharedInstance].userInfoDic[@"realname"];
    if([[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"] length] > 0)
    {
        [self.userIcon sd_setImageWithURL:[NSURL URLWithString:[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"]]];
        
    }
    else
    {
        self.userIcon.image = [UIImage imageNamed:@"xiaolu.jpg"];
    }
    
    if([[DemoGlobalClass sharedInstance].userInfoDic[@"realname"] length] > 0)
    {
        self.userName.text = [DemoGlobalClass sharedInstance].userInfoDic[@"realname"];
    }}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI
{
    self.setView.userInteractionEnabled = YES;
    self.setView.layer.borderWidth = 0.5;
    self.setView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.setView.layer.masksToBounds = YES;
    
    
    //介绍
//    self.introduceView.userInteractionEnabled = YES;
//    [self.introduceView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(introduceTap)]];
    
    
    self.feedbackView.userInteractionEnabled = YES;
    [self.feedbackView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedbackTap)]];
    
    UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.setView addGestureRecognizer:gr];
    
    [self.MessageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Messagetap:)]];
    
    [self.favoriteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FavoriteTap:)]];
    
    
    if([[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"] length] > 0)
    {
        [self.userIcon sd_setImageWithURL:[NSURL URLWithString:[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"]]];
        
    }
    else
    {
        self.userIcon.image = [UIImage imageNamed:@"xiaolu.jpg"];
    }
    
    if([[DemoGlobalClass sharedInstance].userInfoDic[@"realname"] length] > 0)
    {
        self.userName.text = [DemoGlobalClass sharedInstance].userInfoDic[@"realname"];
    }
    [self.logoutView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    self.logoutView.userInteractionEnabled = YES;
    
    self.deleteView.userInteractionEnabled = YES;
    [self.deleteView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteTap)]];
}

-(void)deleteTap
{
    UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"Avertissement" message:@"Efface l'enregistrement de conversation?" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"OK", nil];
    av.tag = 1002;
    [av show];
    
    
    
}

-(void)introduceTap
{
    
}

-(void)feedbackTap
{
    FeedBackViewController * fvc = [FeedBackViewController new];
    
    [[AppDelegate getNav] pushViewController:fvc animated:YES];
}

-(void)Messagetap:(UITapGestureRecognizer *)tap
{
    HostMessageViewController * mvc = [HostMessageViewController new];
    
    [[AppDelegate getNav] pushViewController:mvc animated:YES];
}

-(void)tap
{
    PersonSetController * psc = [PersonSetController new];
    [self.navigationController pushViewController:psc animated:YES];
}

-(void)tap:(UITapGestureRecognizer *)tap
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Pointe" message:@"Vraiment doit annuler?" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Oui", nil];
    av.tag = 1001;
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
    
//        注销
        if(buttonIndex == 1)
        {
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.removeFromSuperViewOnHide = YES;
            hub.labelText = @"Déconnecté...";
            [[ECDevice sharedInstance] logout:^(ECError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_Connacts];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_LoginUser];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_KickedOff]];
                
            }];
        }
    }
    else
    {
        //清空聊天记录
        
        if (buttonIndex == 1)
        {
            [[DeviceDBHelper sharedInstance].msgDBAccess clearMessageTable];
            [MBProgressHUD creatembHub:@"De succès"];
        }
        
    }
    
    
}

-(void)FavoriteTap:(UITapGestureRecognizer *)tap
{
    FavoriteViewController * vc = [[FavoriteViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
