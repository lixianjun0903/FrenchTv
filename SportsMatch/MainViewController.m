//
//  ViewController.m
//  SportsMatch
//
//  Created by mac on 15/2/12.
//  Copyright (c) 2015年 wsd. All rights reserved.
//

#import "MainViewController.h"
#import "DateView.h"


#define MakeRgbColor(r,g,b,a)       [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height  [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()
{
    UIScrollView * sv;
    
    UIScrollView * dateView;
    
}
@property (strong,nonatomic)UIView * v;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self setButtonSelected];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)createUI
{
     self.view.backgroundColor = MakeRgbColor(246, 246, 246, 1);
    
   self.v = [[UIView alloc] initWithFrame:CGRectMake(0,20 , 320, 40)];
    self.v.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.v];
    
    
    sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 58, 80, 2)];
    
    sv.backgroundColor = MakeRgbColor(15, 108, 168, 1);
    
    [self.view addSubview:sv];
    
    NSArray * buttonArray = @[@"直播",@"点播",@"日程",@"咨询"];
    
    UIButton * button;
    
    for(int i = 0;i < 4;i++)
    {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.frame = CGRectMake(i * 80 + 20, 10, 40, 20);
        
        button.tag = 100 + i;
        
        [button addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:MakeRgbColor(76, 136, 182, 1) forState:UIControlStateSelected];
        
        [button setTitle:buttonArray[i] forState:UIControlStateNormal];
        
        [self.v addSubview:button];
    }
   
    
    //底部4个按钮
//    NSArray * buttonUnSelectImageArray = @[@"09",@"10",@"14",@"12"];
//    NSArray * buttonSelectImageArray = @[@"16",@"15",@"11",@"13"];
//    for(int i = 0;i < buttonSelectImageArray.count;i++)
//    {
//        button = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//        button.frame = CGRectMake(i * Screen_Width / 4, Screen_Height - 50, Screen_Width / 4, 50);
//        
//        [button setImage:[UIImage imageNamed:buttonUnSelectImageArray[i]] forState:UIControlStateNormal];
//        
//        [button setImage:[UIImage imageNamed:buttonSelectImageArray[i]] forState:UIControlStateSelected];
//        
//        button.tag = 200 + i;
//        
//        [button addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self.view addSubview:button];
//    }
    
    
}

-(void)setButtonSelected
{
    UIButton * butn = (UIButton *)[self.v viewWithTag:100];
    butn.selected = YES;
}


-(void)ButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            [UIView animateWithDuration:0.3 animations:^{
                sv.frame = CGRectMake(0, 58, 80, 2);
            }];
            sender.selected = YES;
            UIButton * button1 = (UIButton *)[self.v viewWithTag:101];
            UIButton * button2 = (UIButton *)[self.v viewWithTag:102];
            UIButton * button3 = (UIButton *)[self.v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
            
        }
            break;
        case 101:
        {
            [UIView animateWithDuration:0.3 animations:^{
                sv.frame = CGRectMake(80, 58, 80, 2);
            }];
            sender.selected = YES;
            UIButton * button1 = (UIButton *)[self.v viewWithTag:100];
            UIButton * button2 = (UIButton *)[self.v viewWithTag:102];
            UIButton * button3 = (UIButton *)[self.v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
            for(UIView * view in self.view.subviews)
            {
                if([view isKindOfClass:[DateView class]])
                {
                    [view removeFromSuperview];
                }
            }
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
                  }
            break;
        case 102:
        {
            [UIView animateWithDuration:0.3 animations:^{
                sv.frame = CGRectMake(160, 58, 80, 2);
            }];
            sender.selected = YES;
            UIButton * button1 = (UIButton *)[self.v viewWithTag:101];
            UIButton * button2 = (UIButton *)[self.v viewWithTag:100];
            UIButton * button3 = (UIButton *)[self.v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
            DateView * date = [[DateView alloc] initWithFrame:CGRectMake(0, 61, 320, 507)];
            [self.view addSubview:date];
            
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
        }
            break;
        case 103:
        {
            [UIView animateWithDuration:0.3 animations:^{
                sv.frame = CGRectMake(240, 58, 80, 2);
            }];
            sender.selected = YES;
            
            UIButton * button1 = (UIButton *)[self.v viewWithTag:101];
            UIButton * button2 = (UIButton *)[self.v viewWithTag:102];
            UIButton * button3 = (UIButton *)[self.v viewWithTag:100];
//            UIButton * button4 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
            button1.selected = NO;
            button2.selected = NO;
            button3.selected = NO;
            
            for(UIView * view in self.view.subviews)
            {
                if([view isKindOfClass:[DateView class]])
                {
                    [view removeFromSuperview];
                }
            }
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
        }
            break;
//        case 200:
//        {
//            sv.frame = CGRectMake(0, 0, 0, 0);
//            
//            sender.selected = YES;
//            
//            UIButton * button1 = (UIButton *)[v viewWithTag:101];
//            UIButton * button2 = (UIButton *)[v viewWithTag:102];
//            UIButton * button3 = (UIButton *)[v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[v viewWithTag:100];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//        }
//            break;
//        case 201:
//        {
//            sv.frame = CGRectMake(0, 0, 0, 0);
//            
//            sender.selected = YES;
//            
//            UIButton * button1 = (UIButton *)[v viewWithTag:101];
//            UIButton * button2 = (UIButton *)[v viewWithTag:102];
//            UIButton * button3 = (UIButton *)[v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[v viewWithTag:100];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//        }
//            break;
//        case 202:
//        {
//            sv.frame = CGRectMake(0, 0, 0, 0);
//            
//            sender.selected = YES;
//            
//            UIButton * button1 = (UIButton *)[v viewWithTag:101];
//            UIButton * button2 = (UIButton *)[v viewWithTag:102];
//            UIButton * button3 = (UIButton *)[v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[v viewWithTag:100];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:200];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:203];
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//        }
//            break;
//        case 203:
//        {
//            sv.frame = CGRectMake(0, 0, 0, 0);
//            
//            sender.selected = YES;
//            
//            UIButton * button1 = (UIButton *)[v viewWithTag:101];
//            UIButton * button2 = (UIButton *)[v viewWithTag:102];
//            UIButton * button3 = (UIButton *)[v viewWithTag:103];
//            UIButton * button4 = (UIButton *)[v viewWithTag:100];
//            UIButton * button5 = (UIButton *)[self.view viewWithTag:201];
//            UIButton * button6 = (UIButton *)[self.view viewWithTag:202];
//            UIButton * button7 = (UIButton *)[self.view viewWithTag:200];
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//            button4.selected = NO;
//            button5.selected = NO;
//            button6.selected = NO;
//            button7.selected = NO;
//            button1.selected = NO;
//            button2.selected = NO;
//            button3.selected = NO;
//        }
//            break;
        default:
            break;
    }
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
