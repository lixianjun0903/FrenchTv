//
//  NoticeActivityCell.m
//  FrenchTV
//
//  Created by gaobo on 15/3/5.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "NoticeActivityCell.h"

@interface NoticeActivityCell ()

{
    UILabel * titleLab;
    UILabel * detailLab;
    UIImageView * imgV;
    UIButton * btn;
}

@end

@implementation NoticeActivityCell

- (void)awakeFromNib {
    // Initialization code
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self makeUI];

    }
    return self;
}

-(void)config:(NoticeCellModel *)mod
{
    NSLog(@"%@",mod.contentAbstract);
    
    titleLab.text = mod.contentTitle;
    detailLab.text = mod.contentAbstract;
//    if ([mod.contentModel isEqualToString:@"公告"]) {
//        btn.hidden = YES;
//    }
    
    if ([mod.firstImg isEqualToString:@""]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
        btn.frame = CGRectMake(SCREEN_WIDTH - 45, self.bounds.size.height - 30, 45, 30);
        [imgV removeFromSuperview];
    }
    else
    {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        [imgV sd_setImageWithURL:[NSURL URLWithString:mod.firstImg]];
        btn.frame = CGRectMake(SCREEN_WIDTH - 45, self.bounds.size.height - 30, 45, 30);

    }
    
}

-(void)makeUI
{
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200, 30)];
    titleLab.text = @"COMPERE";
    titleLab.font = [UIFont boldSystemFontOfSize:20];
    [self addSubview:titleLab];
    
    
    detailLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH - 50, 15)];
    detailLab.text = @"COMPERE with me OMPERE with me OMPERE with me OMPERE with me OMPERE with me ";
    detailLab.textColor = [UIColor lightGrayColor];
    detailLab.font = [UIFont systemFontOfSize:15];
    
    [self addSubview:detailLab];
    
    imgV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 70, 150, 110)];
    imgV.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:imgV];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH - 45, self.bounds.size.height - 30, 45, 30);
    [btn setImage:[UIImage imageNamed:@"45"] forState:UIControlStateNormal];
    btn.imageView.contentMode = UIViewContentModeLeft;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
}

-(void)btnClick
{
    self.myblock();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
