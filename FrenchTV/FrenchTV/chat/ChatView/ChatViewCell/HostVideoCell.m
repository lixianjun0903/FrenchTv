//
//  HostVideoCell.m
//  FrenchTV
//
//  Created by mac on 15/3/12.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "HostVideoCell.h"

@implementation HostVideoCell

{
    UIImageView* _displayImage;
    UIButton * _playBtn;
    UILabel * _introduce;
    NSString * videoUrl;

}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        [_displayImage setImage:[UIImage imageNamed:@"30"]];
        _playBtn = [[UIButton alloc]init];
        _playBtn.alpha = 0.7;
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"55"] forState:UIControlStateNormal];
        _introduce = [[UILabel alloc] init];
        _introduce.textColor = [UIColor blackColor];
        _introduce.text = @"SUJAILSNDWQ";
        _introduce.font = [UIFont systemFontOfSize:13];
        _introduce.numberOfLines = 0;
        _introduce.textColor = [UIColor grayColor];
        
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(135, 8, 63, 63);
            _introduce.frame = CGRectMake(15, 5, 120, 75);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-230, self.portraitImg.frame.origin.y-5, 220.0f, 80.0f);
            
        }else{
            
            _displayImage.frame = CGRectMake(135, 8, 63, 63);
            _introduce.frame = CGRectMake(15, 5, 120, 75);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 220.0f, 80.0f);
            
        }
        
        _playBtn.frame = CGRectMake(_displayImage.frame.origin.x+23.0f, _displayImage.frame.origin.y+20.0f, 25.0f, 25.0f);
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_introduce];
        [self.bubbleView addSubview:_playBtn];
    }
    return self;
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 100.0f;
}


-(void)config:(NSDictionary *)dataDic
{
    if(!dataDic)
    {
        return;
    }
//    _introduce.text = dataDic[@"content"][@"contentTxt"];
    videoUrl = dataDic[@"contentMediaPath"];
    _introduce.text = dataDic[@"contentTxt"];
    [_displayImage sd_setImageWithURL:[NSURL URLWithString:dataDic[@"imgUrl"]]];
    
}

-(void)bubbleViewTapGesture:(id)sender{
    return;
}


-(void)playVideo
{
    self.playBlock(videoUrl);
}



@end
