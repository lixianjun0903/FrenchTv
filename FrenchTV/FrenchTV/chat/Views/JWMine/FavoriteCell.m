//
//  FavoriteCell.m
//  FrenchTV
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "FavoriteCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CCAudioPlayer.h"
#import "CreateCCAudio.h"

@interface FavoriteCell ()
{
    int MusicId;
    NSString * musicUrl;
    CCAudioPlayer * play;
    UIImageView * StateImage;
    UIButton * recordButn;
    
}
@end

@implementation FavoriteCell
@synthesize Slider1;
- (void)awakeFromNib {
    
    Slider1.backgroundColor = [UIColor clearColor];
    [Slider1 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateNormal];
    [Slider1 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateHighlighted];
    //    [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:114 / 255.0 green:197 / 255.0 blue:186 / 255.0 alpha:1]];
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"ProAL"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"ProNL"];
    [Slider1 setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [Slider1 setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [Slider1 addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    Slider1.tag = 50;
    
    
}

-(void)updateProgressView
{
    double proNum = play.progress / play.duration;
    Slider1.value = proNum;
}

-(void)_actionSliderProgress:(UISlider *)sender
{
    [play seekToTime:play.duration * sender.value];
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        [self updateProgressView];
    }else
    {
        [self updateState];
    }
}

-(void)updateState
{
    if(play.playerState == CCAudioPlayerStateBuffering)
    {
        if(!StateImage)
        {
            StateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, recordButn.frame.size.width, recordButn.frame.size.height)];
            StateImage.image = [UIImage imageNamed:@"70"];
            
            [recordButn addSubview:StateImage];
            
        }
        StateImage.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(trans) userInfo:nil repeats:YES];
        recordButn.selected = NO;
    }
    
    if(play.playerState == CCAudioPlayerStateDisposed)
    {
        recordButn.selected = NO;
        [StateImage removeFromSuperview];
        StateImage = nil;
        Slider1.value = 0;
    }
    
    if(play.playerState == CCAudioPlayerStatePaused)
    {
        recordButn.selected = NO;
        
    }
    
    
    
    if(play.playerState == CCAudioPlayerStatePlaying)
    {
        recordButn.selected = YES;
        StateImage.hidden = YES;
    }
}

-(void)trans
{
    static int a = 1;
    [UIView animateWithDuration:0.01 animations:^{
        StateImage.transform = CGAffineTransformMakeRotation(M_1_PI * a / 50);
        a++;
    }];
}

-(void)actionSliderProgress:(UISlider *)sender
{
    
}

- (IBAction)shareClick:(UIButton *)sender {
    
}

- (IBAction)playMusic:(UIButton *)sender {
    if(self.playButton.selected)
    {
        

        [play pause];
    }else
    {
        if(recordButn.tag != sender.tag)
        {
            if(play)
            {
                [play dispose];
                
                [play removeObserver:self forKeyPath:@"progress"];
                [play removeObserver:self forKeyPath:@"playerState"];
                
                play = nil;
            }
        }
        recordButn = sender;
        
        
        if(musicUrl.length > 0)
        {
            
            play = [CreateCCAudio sharedManager:musicUrl];
            if(play != nil)
            {
                [play addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
                [play addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionNew context:nil];
                [play play];
            }else
            {
                [play removeObserver:self forKeyPath:@"progress"];
                [play removeObserver:self forKeyPath:@"playerState"];
                [CreateCCAudio setPlayNil];
                play = nil;
                
                self.Slider1.value = 0;
            }
            
            
        }
        
        
    }
    
}

- (IBAction)CancelCollect:(UIButton *)sender {
    if(MusicId && MusicId != 0)
    {
       [AccountRequest deleteFavoriteWithId:MusicId withSucc:^(NSDictionary * DataDic) {
           if([DataDic[@"status"] intValue] == 0)
           {
               [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelFav" object:nil];
               [MBProgressHUD creatembHub:@"取消收藏成功"];
               
           }
           
       }];
    }
    
}

-(void)config:(NSDictionary *)dataDic
{
    
    self.MusicTitle.text = dataDic[@"contentTitle"];
    MusicId = [dataDic[@"contentId"] intValue];
    musicUrl = dataDic[@"contentMediaPath"];
    self.collect.selected = YES;
}



@end
