//
//  RecomListViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/2/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "RecomListViewController.h"

@interface RecomListViewController ()

@end

@implementation RecomListViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
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
