//
//  WordViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "WordViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WordViewController ()

{
    MPMoviePlayerViewController * play;
}
@property (nonatomic, strong) NSString * audioURl;
@end



@implementation WordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_oldText resignFirstResponder];
    [_fanText resignFirstResponder];
}

- (IBAction)audioClick:(id)sender
{
    if (play) {
        [play.moviePlayer play];
        return;
    }
    
    if (self.audioURl== nil || [self.audioURl isEqualToString:@""]) {
        return;
    }
    
    play=[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:self.audioURl]];
    
    //http://112.231.23.20/live/fhzw/playlist.m3u8
    //设置播放器大小
    play.view.frame=CGRectMake(10, 130, 0, 0);
    //设置缓冲播放
    [play.moviePlayer prepareToPlay];
    
    [self.view addSubview:play.view];
    
    [play.moviePlayer play];

}

- (IBAction)sendBtn:(id)sender
{
    [_oldText resignFirstResponder];
    [_fanText resignFirstResponder];
    if (self.oldText.text.length == 0 || [[self.oldText.text substringToIndex:1] isEqualToString:@" "]) {
        [MBProgressHUD creatembHub:@"输入不符合"];
        return;
    }
    
    [self loadData];
}

-(void)loadData
{
    [AccountRequest LessonSendWord:self.oldText.text withSucc:^(NSDictionary *dic) {
        
        //成功
        self.fanText.text = dic[@"content"];
        if (![dic[@"url"] isEqualToString:@""]) {
            //url处理
            self.audioURl =dic[@"url"];
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
