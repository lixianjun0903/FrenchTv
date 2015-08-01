//
//  RecommendViewController.m
//  PageXib
//
//  Created by mac on 15/2/5.
//  Copyright (c) 2015年 wsd. All rights reserved.
//

#import "JW_RecommendViewController.h"
#import "RecommendCell.h"
#import "AppDelegate.h"

@interface JW_RecommendViewController () <UIWebViewDelegate>

{
    UITableView * _tableView;
    UIWebView *wb;
}

@end

@implementation JW_RecommendViewController


-(void)viewWillAppear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
    
    
    
}

-(void)createNavBar
{
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 0, 40, 25);
    backBtn.tag = 111;
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self createNavBar];
}

-(void)btnClick:(UIButton *)sender

{
    if (sender.tag == 111) {
        [wb goBack];
    }
    else if (sender.tag == 222)
    {
        [wb goForward];
    }
}

-(void)createWebView
{
    wb = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40 - 64)];
    wb.scrollView.bounces = NO;
    [wb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://french.cri.cn/other/iphone2/emission.htm"]]];
    wb.delegate = self;
    [self.view addSubview:wb];
}




@end
