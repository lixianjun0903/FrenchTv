//
//  IntroduceViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/19.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "IntroduceViewController.h"

@interface IntroduceViewController ()

@end

@implementation IntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadData];
}

-(void)loadData
{
    [AccountRequest getIntroduce:^(NSDictionary *dic)
    {
        //成功
        NSLog(@"%@",dic);
        NSString * str = dic[@"introducation"];
        if (![str isEqualToString:@""]) {
            self.introduceView.text = str;
        }
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
