//
//  CommentCell.m
//  FrenchTV
//
//  Created by gaobo on 15/3/27.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    // Initialization code
}



-(void)config:(NSDictionary *)dic
{
    self.nameLab.text = dic[@"commentUserName"];
    self.commentLab.text = dic[@"commentText"];
    self.timeLab.text = dic[@"commentTime"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
