//
//  MainLoginViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "MainLoginViewController.h"
#import "JWLoginViewController.h"

@interface MainLoginViewController ()

@end

@implementation MainLoginViewController
- (IBAction)loginClick:(id)sender {
    [[AppDelegate getNav] pushViewController:[JWLoginViewController new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)FacebookLoginClick:(UIButton *)sender {
}
- (IBAction)IntoLoginViewClick:(UIButton *)sender {
}
@end
