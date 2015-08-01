//
//  JW_ClassViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/13.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JW_ClassViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *ClassView;
@property (weak, nonatomic) IBOutlet UILabel *VideoLable;
@property (weak, nonatomic) IBOutlet UIView *FrenchView;
@property (weak, nonatomic) IBOutlet UIView *FrenchView2;
@property (weak, nonatomic) IBOutlet UIView *FrenchView3;
@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
//视频收藏
@property (weak, nonatomic) IBOutlet UIButton *videoFav;
//音频收藏
@property (weak, nonatomic) IBOutlet UIButton *voiceFav1;
@property (weak, nonatomic) IBOutlet UIButton *voiceFav2;
@property (weak, nonatomic) IBOutlet UIButton *voiceFav3;


- (IBAction)share:(UIButton *)sender;
- (IBAction)favorite:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *WebcontentView;

@property (weak, nonatomic) IBOutlet UIProgressView *firstVideoPro;
@property (weak, nonatomic) IBOutlet UIProgressView *secondVideoPro;
@property (weak, nonatomic) IBOutlet UIProgressView *thirdVideoPro;

@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;
@property (weak, nonatomic) IBOutlet UILabel *firstVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdVideoTitle;

@property (weak, nonatomic) IBOutlet UIButton *firPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *secPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *ThrPlayBtn;

- (IBAction)firstvideoPlay:(UIButton *)sender;


- (IBAction)secondvideoplay:(UIButton *)sender;


- (IBAction)thirdvideoplay:(UIButton *)sender;


- (IBAction)IntoClass:(UIButton *)sender;
- (IBAction)VideoPlay:(UIButton *)sender;
- (IBAction)IntoWebView:(UIButton *)sender;

@end
