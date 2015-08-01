//
//  TopicCell.h
//  FrenchTV
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *playVideo;
@property (weak, nonatomic) IBOutlet UIImageView *topicImage;
@property (strong,nonatomic) UIViewController * controller;
@property (strong,nonatomic) void(^playClickBlock)(NSString *);
- (IBAction)playClick:(UIButton *)sender;
-(void)config:(NSDictionary *)dataDic;
@end
