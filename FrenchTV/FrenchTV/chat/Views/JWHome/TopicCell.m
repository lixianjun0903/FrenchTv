//
//  TopicCell.m
//  FrenchTV
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "TopicCell.h"

@interface TopicCell ()
{
    
}
@property (strong,nonatomic)NSString * videoUrl;
@end

@implementation TopicCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)playClick:(UIButton *)sender {
    
    self.playClickBlock(self.videoUrl);
}

-(void)config:(NSDictionary *)dataDic
{
    if([dataDic[@"type"] isEqualToString:@"image"])
    {
        [self.topicImage sd_setImageWithURL:[NSURL URLWithString:dataDic[@"imgUrl"]]];
        self.playVideo.hidden = YES;
    }
    
    if([dataDic[@"type"] isEqualToString:@"media"])
    {
        self.playVideo.hidden = NO;
        self.playVideo.center = self.contentView.center;
        self.videoUrl = dataDic[@"mediaUrl"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
