//
//  RecommendCell.m
//  FrenchTV
//
//  Created by mac on 15/2/5.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "RecommendCell.h"
#import "RecommendView.h"

#define IMAGE_WIDTH ([UIScreen mainScreen].bounds.size.width - 30)/2

@interface RecommendCell ()
{
    RecommendView * ltView;
    RecommendView * rtView;
}

@end

@implementation RecommendCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier

{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self makeUI];
    }
    
    return self;
}


-(void)makeUI
{
    ltView = [[RecommendView alloc]initWithFrame:CGRectMake(10, 10, IMAGE_WIDTH, IMAGE_WIDTH)];
    
    rtView = [[RecommendView alloc]initWithFrame:CGRectMake(20 + IMAGE_WIDTH, 10, IMAGE_WIDTH, IMAGE_WIDTH)];
    
    
    [self addSubview:ltView];
    [self addSubview:rtView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
