//
//  LessonViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/13.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "LessonViewController.h"

@interface LessonViewController ()

{
    UIWebView * _webView;
    UIButton * backBtn;
}
@end

@implementation LessonViewController

-(void)viewWillAppear:(BOOL)animated
{
    backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0, 0, 40, 25);
    backBtn.tag = 111;
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createNavBar];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44)];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://french.cri.cn/other/iphone2/chinois.htm"]];
    [self.view addSubview:_webView];
    [_webView loadRequest:request];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
}

-(void)createNavBar
{
//    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    backBtn.frame = CGRectMake(0, 0, 40, 25);
//    backBtn.tag = 111;
//    [backBtn setTitle:@"back" forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];

    UIButton * goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    goBtn.frame = CGRectMake(0, 0, 60, 25);
    goBtn.tag = 222;
    [goBtn setTitle:@"forward" forState:UIControlStateNormal];
    [goBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:goBtn];
    
    
}

-(void)btnClick:(UIButton *)sender

{
    if (sender.tag == 111) {
        [_webView goBack];
    }
    else if (sender.tag == 222)
    {
        [_webView goForward];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
