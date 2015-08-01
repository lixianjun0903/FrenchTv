//
//  FavoriteCell.h
//  FrenchTV
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteViewController.h"

@interface FavoriteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *MusicTitle;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *Slider1;
@property (strong,nonatomic) FavoriteViewController * Controller;
- (IBAction)shareClick:(UIButton *)sender;
- (IBAction)playMusic:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *collect;
- (IBAction)CancelCollect:(UIButton *)sender;


-(void)config:(NSDictionary *)dataDic;

@end
