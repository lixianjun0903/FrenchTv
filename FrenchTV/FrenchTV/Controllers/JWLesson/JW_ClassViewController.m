//
//  JW_ClassViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/13.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "JW_ClassViewController.h"
#import "LessonViewController.h"
#import "WordViewController.h"
#import "ClassChatViewController.h"
#import "CCAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>


@interface JW_ClassViewController () <UMSocialUIDelegate>
{
    MPMoviePlayerViewController * play;
    NSString * movieUrl;
    NSString * movieImageUrl;
    NSString * videoUrl1;
    NSString * videoUrl2;
    NSString * videoUrl3;
    
    CCAudioPlayer * audioPlayer;
    
    UISlider * slider1;
    UISlider * slider2;
    UISlider * slider3;
    
    
    UIButton * recordButn;
    
    UIImageView * proImage1;
    UIImageView * StateImage;
    
    int videoId;
    int voiceId1;
    int voiceId2;
    int voiceId3;
}

@end

@implementation JW_ClassViewController

-(void)viewDidAppear:(BOOL)animated
{
    self.backScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 150);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}



-(void)initUI
{
    self.VideoLable.layer.bounds = self.VideoLable.bounds;
    self.VideoLable.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.VideoLable.layer.shadowOffset = CGSizeMake(0, 1);
    self.VideoLable.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.VideoLable.layer.shadowRadius = 2;
    self.VideoLable.layer.shadowOpacity = 0.5;
    
    self.ClassView.layer.bounds = self.VideoLable.bounds;
    self.ClassView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.ClassView.layer.shadowOffset = CGSizeMake(0, 1);
    self.ClassView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.ClassView.layer.shadowRadius = 2;
    self.ClassView.layer.shadowOpacity = 0.5;
    self.ClassView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(webTap)];
    [self.ClassView addGestureRecognizer:tap];
    
    self.FrenchView.layer.bounds = self.VideoLable.bounds;
    self.FrenchView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.FrenchView.layer.shadowOffset = CGSizeMake(0, 1);
    self.FrenchView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.FrenchView.layer.shadowRadius = 2;
    self.FrenchView.layer.shadowOpacity = 0.5;
    
    self.FrenchView2.layer.bounds = self.VideoLable.bounds;
    self.FrenchView2.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.FrenchView2.layer.shadowOffset = CGSizeMake(0, 1);
    self.FrenchView2.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.FrenchView2.layer.shadowRadius = 2;
    self.FrenchView2.layer.shadowOpacity = 0.5;
    
    self.FrenchView3.layer.bounds = self.VideoLable.bounds;
    self.FrenchView3.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.FrenchView3.layer.shadowOffset = CGSizeMake(0, 1);
    self.FrenchView3.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.FrenchView3.layer.shadowRadius = 2;
    self.FrenchView3.layer.shadowOpacity = 0.5;
    
    self.WebcontentView.layer.bounds = self.VideoLable.bounds;
    self.WebcontentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.WebcontentView.layer.shadowOffset = CGSizeMake(0, 1);
    self.WebcontentView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.WebcontentView.layer.shadowRadius = 2;
    self.WebcontentView.layer.shadowOpacity = 0.5;
    self.firstVideoPro.hidden = YES;
    self.secondVideoPro.hidden = YES;
    self.thirdVideoPro.hidden = YES;
    [self createSliders];
    
    [self loadData];
}

-(void)createSliders
{
    slider1 = [[UISlider alloc] initWithFrame:self.firstVideoPro.frame];
    slider1.backgroundColor = [UIColor clearColor];
    [slider1 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateNormal];
    [slider1 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateHighlighted];
    //    [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:114 / 255.0 green:197 / 255.0 blue:186 / 255.0 alpha:1]];
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"ProAL"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"ProNL"];
    [slider1 setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [slider1 setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    [slider1 addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    slider1.tag = 50;
    [self.FrenchView addSubview:slider1];
    
    slider2 = [[UISlider alloc] initWithFrame:self.secondVideoPro.frame];
    slider2.backgroundColor = [UIColor clearColor];
    [slider2 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateNormal];
    [slider2 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateHighlighted];
    //    [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:114 / 255.0 green:197 / 255.0 blue:186 / 255.0 alpha:1]];
    UIImage *stetchLeftTrack2= [UIImage imageNamed:@"ProAL"];
    UIImage *stetchRightTrack2 = [UIImage imageNamed:@"ProNL"];
    [slider2 setMinimumTrackImage:stetchLeftTrack2 forState:UIControlStateNormal];
    [slider2 setMaximumTrackImage:stetchRightTrack2 forState:UIControlStateNormal];
    [slider2 addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    slider2.tag = 51;
    [self.FrenchView2 addSubview:slider2];
    
    slider3 = [[UISlider alloc] initWithFrame:self.firstVideoPro.frame];
    slider3.backgroundColor = [UIColor clearColor];
    [slider3 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateNormal];
    [slider3 setThumbImage:[UIImage imageNamed:@"proButn"] forState:UIControlStateHighlighted];
    //    [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:114 / 255.0 green:197 / 255.0 blue:186 / 255.0 alpha:1]];
    UIImage *stetchLeftTrack3= [UIImage imageNamed:@"ProAL"];
    UIImage *stetchRightTrack3 = [UIImage imageNamed:@"ProNL"];
    [slider3 setMinimumTrackImage:stetchLeftTrack3 forState:UIControlStateNormal];
    [slider3 setMaximumTrackImage:stetchRightTrack3 forState:UIControlStateNormal];
    [slider3 addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    slider3.tag = 52;
    [self.FrenchView3 addSubview:slider3];
    
    
}

-(void)_actionSliderProgress:(UISlider *)sender
{
    [audioPlayer seekToTime:audioPlayer.duration * sender.value];
}


-(void)loadData
{
    [AccountRequest getChineseClass:^(NSDictionary * dataDic) {
        movieUrl = dataDic[@"contentList"][0][@"contentMediaPath"];
        movieImageUrl = dataDic[@"contentList"][0][@"contentMediaImg"];
        
        videoId = [dataDic[@"contentList"][0][@"contentId"] intValue];
        voiceId1 = [dataDic[@"contentList"][1][@"contentId"] intValue];
        voiceId2 = [dataDic[@"contentList"][2][@"contentId"] intValue];
        voiceId3 = [dataDic[@"contentList"][3][@"contentId"] intValue];
        if([dataDic[@"contentList"][0][@"isCollected"] intValue] == 0)
        {
            self.videoFav.selected = YES;
        }else
        {
            self.videoFav.selected = NO;
        }
        if([dataDic[@"contentList"][1][@"isCollected"] intValue] == 0)
        {
            self.voiceFav1.selected = YES;
        }else
        {
            self.voiceFav1.selected = NO;
        }
        if([dataDic[@"contentList"][2][@"isCollected"] intValue] == 0)
        {
            self.voiceFav2.selected = YES;
        }else
        {
            self.voiceFav2.selected = NO;
        }
        if([dataDic[@"contentList"][3][@"isCollected"] intValue] == 0)
        {
            self.voiceFav3.selected = YES;
        }else
        {
            self.voiceFav3.selected = NO;
        }
        
        [self.movieImage sd_setImageWithURL:[NSURL URLWithString:movieImageUrl]];
        
        videoUrl1 = dataDic[@"contentList"][1][@"contentMediaPath"];
        videoUrl2 = dataDic[@"contentList"][2][@"contentMediaPath"];
        videoUrl3 = dataDic[@"contentList"][3][@"contentMediaPath"];
        
        self.firstVideoTitle.text = dataDic[@"contentList"][1][@"contentTitle"];
        self.secondVideoTitle.text = dataDic[@"contentList"][2][@"contentTitle"];
        self.thirdVideoTitle.text = dataDic[@"contentList"][3][@"contentTitle"];
        
    }];
}

-(void)webTap
{
    LessonViewController * lvc = [[LessonViewController alloc]init];
    
    [[AppDelegate getNav] pushViewController:lvc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (IBAction)firstvideoPlay:(UIButton *)sender {
    
    
    if(!sender.selected)
    {
        if(recordButn.tag != sender.tag)
        {
            if(audioPlayer)
            {
                [audioPlayer dispose];
                
                [audioPlayer removeObserver:self forKeyPath:@"progress"];
                [audioPlayer removeObserver:self forKeyPath:@"playerState"];
                
                audioPlayer = nil;
            }
        }
        
        recordButn = sender;
        
        if(videoUrl1.length > 0)
        {
            if (audioPlayer) {
                [audioPlayer play];
                
                return;
            }
            
            audioPlayer = [[CCAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:videoUrl1]];
            [audioPlayer addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
            [audioPlayer addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionNew context:nil];
            [audioPlayer play];
            
            

        }else
        {
            recordButn = sender;
            return;
        }
    }else
    {
        [audioPlayer pause];
        
        
        
        
        
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
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
    if(audioPlayer.playerState == CCAudioPlayerStateBuffering)
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
    
    if(audioPlayer.playerState == CCAudioPlayerStateDisposed)
    {
        recordButn.selected = NO;
        [StateImage removeFromSuperview];
        StateImage = nil;
        slider1.value = 0;
        slider2.value = 0;
        slider3.value = 0;
    }
    
    if(audioPlayer.playerState == CCAudioPlayerStatePaused)
    {
        recordButn.selected = NO;
        
    }
    
    
    
    if(audioPlayer.playerState == CCAudioPlayerStatePlaying)
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


-(void)updateProgressView
{
    double proNum = audioPlayer.progress / audioPlayer.duration;
    switch (recordButn.tag) {
        case 100:
        {
            slider1.value = proNum;
        }
            break;
        case 101:
        {
            slider2.value = proNum;
        }
            break;
        case 102:
        {
            slider3.value = proNum;
        }
            break;
        default:
            break;
    }
}



- (IBAction)secondvideoplay:(UIButton *)sender {
    
    if(!sender.selected)
    {
        if(recordButn.tag != sender.tag)
        {
            if(audioPlayer)
            {
                [audioPlayer dispose];
                
                [audioPlayer removeObserver:self forKeyPath:@"progress"];
                [audioPlayer removeObserver:self forKeyPath:@"playerState"];
                
                audioPlayer = nil;
            }
        }
        recordButn = sender;
        
        
        if(videoUrl2.length > 0)
        {
            if (audioPlayer) {
                [audioPlayer play];
                
                return;
            }
            
            audioPlayer = [[CCAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:videoUrl2]];
            [audioPlayer addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
            [audioPlayer addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionNew context:nil];
            [audioPlayer play];
            
            
        }else
        {
            return;
        }

    }else
    {
        [audioPlayer pause];
        
        
    }
    
    
    
}



- (IBAction)thirdvideoplay:(UIButton *)sender {
    
    if(!sender.selected)
    {
        if(recordButn.tag != sender.tag)
        {
            if(audioPlayer)
            {
                [audioPlayer dispose];
                
                [audioPlayer removeObserver:self forKeyPath:@"progress"];
                [audioPlayer removeObserver:self forKeyPath:@"playerState"];
                
                audioPlayer = nil;
            }
  
        }
        recordButn = sender;
        if(videoUrl2.length > 0)
        {
            if (audioPlayer) {
                [audioPlayer play];
                
                return;
            }
            
            audioPlayer = [[CCAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:videoUrl3]];
            [audioPlayer addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
            [audioPlayer addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionNew context:nil];
            [audioPlayer play];
            
            
        }else
        {
            return;
        }
        
    }else
    {
        [audioPlayer pause];
        
        
    }
    
    
    
}


- (IBAction)IntoClass:(UIButton *)sender
{
    
    
    ClassChatViewController * vc = [ClassChatViewController new];
    
    [[AppDelegate getNav] pushViewController:vc animated:YES];

}

- (IBAction)VideoPlay:(UIButton *)sender {
    play = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:movieUrl]];
    
    play.view.frame=CGRectMake(0, self.view.center.y - 184 , 320, 240);
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    view.backgroundColor = [UIColor whiteColor];
    [play.view addSubview:view];
    [play.moviePlayer prepareToPlay];
    [play.moviePlayer play];
    [self.view addSubview:play.view];
}

-(void)movieFinish{
    NSLog(@"1111");
    [play.view removeFromSuperview];
}

- (IBAction)IntoWebView:(UIButton *)sender {
    
    LessonViewController * lvc = [[LessonViewController alloc]init];
    
    [[AppDelegate getNav] pushViewController:lvc animated:YES];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [audioPlayer dispose];
    
    
    [audioPlayer removeObserver:self forKeyPath:@"progress"];
    
    
    audioPlayer = nil;
}
- (IBAction)share:(UIButton *)sender {
//    [self shareClick];
}

#pragma mark 分享


- (IBAction)favorite:(UIButton *)sender {
    switch (sender.tag) {
        case 200:
        {
            if(self.voiceFav1.selected)
            {
                ECNoTitleAlert(@"您已经收藏过了");
                return;
            }
            [AccountRequest addFavoriteWithId:voiceId1 withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0)
                {
                    [MBProgressHUD creatembHub:stateDic[@"message"]];
                    self.voiceFav1.selected = YES;
                }
            }];
        }
            break;
        case 201:
        {
            if(self.voiceFav2.selected)
            {
                ECNoTitleAlert(@"您已经收藏过了");
                return;
            }
            [AccountRequest addFavoriteWithId:voiceId2 withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0)
                {
                    [MBProgressHUD creatembHub:stateDic[@"message"]];
                    self.voiceFav2.selected = YES;
                }
            }];
        }
            break;
        case 202:
        {
            if(self.voiceFav3.selected)
            {
                ECNoTitleAlert(@"您已经收藏过了");
                return;
            }
            [AccountRequest addFavoriteWithId:voiceId3 withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0)
                {
                    [MBProgressHUD creatembHub:stateDic[@"message"]];
                    self.voiceFav3.selected = YES;
                }
            }];
        }
            break;
        case 203:
        {
            if(self.videoFav.selected)
            {
                ECNoTitleAlert(@"您已经收藏过了");
                return;
            }
            [AccountRequest addFavoriteWithId:videoId withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0)
                {
                    [MBProgressHUD creatembHub:stateDic[@"message"]];
                    self.videoFav.selected = YES;
                }
            }];
        }
            break;
        default:
            break;
    }
}
@end
