//
//  MainTabBarControllerViewController.m
//  PageXib
//
//  Created by mac on 15/2/5.
//  Copyright (c) 2015年 wsd. All rights reserved.
//

#import "MainTabBarController.h"
#import "JW_HomeViewController.h"
#import "JW_PersonalInfoViewController.h"
#import "JW_ClassViewController.h"
#import "JW_RecommendViewController.h"
#import "FlipSquaresNavigationController.h"

#import "JW_HostAnswerViewController.h"

@interface MainTabBarController ()
{
    int unReadNum;
}

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
    unReadNum = 0;
    
    // Do any additional setup after loading the view.
}

-(void)createViews
{
    JW_HomeViewController * hvc = [[JW_HomeViewController alloc] init];
    
    
    
//    JW_RecommendViewController * rvc = [[JW_RecommendViewController alloc] init];
//    rvc.title = @"Émissions";
//    
//    JW_ClassViewController * cvc = [[JW_ClassViewController alloc] init];
    JW_PersonalInfoViewController * vc = [[JW_PersonalInfoViewController alloc] init];
    //JW_HostAnswerViewController * avc = [[JW_HostAnswerViewController alloc] init];
    self.viewControllers = @[hvc,vc];
    [self createItems];
}

-(void)createItems
{
    NSArray * unSelectArr = @[@"hostChat",@"hostMessage"];
    NSArray * selectArr = @[@"hostChatSel",@"hostMessageSel"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNumber:) name:@"UnReadChange" object:nil];
    
    
    for (int i = 0; i < 2; i ++) {
        
        UITabBarItem * item =  [self.tabBar.items[i] initWithTitle:nil image:[UIImage imageNamed:unSelectArr[i]] selectedImage:[UIImage imageNamed:selectArr[i]]];
        
//        if (i == 1) {
//            item.imageInsets = UIEdgeInsetsMake(5, 5, -5, -5);
//
//        }
//        else if (i == 2)
//        {
//            item.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
//        }
//        else
//        {
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

//        }
        
    }
    
    
}

-(void)changeNumber:(NSNotification *)notify
{
    
    UITabBarItem * item = self.tabBar.items[0];
    
    AppDelegate * delegate = [UIApplication sharedApplication].delegate;
    
    unReadNum = delegate.unReadNum;
    
    if(unReadNum == 0)
    {
        item.badgeValue = nil;
    }else
    {
        item.badgeValue = [NSString stringWithFormat:@"%d",unReadNum];
    }
    

}

-(UIImage *)loadImageName:(NSString *)imageName
{
    UIImage * image = [UIImage imageWithContentsOfFile:imageName];
    //处理阴影,用图片原数据
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
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
