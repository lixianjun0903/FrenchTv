//
//  RecommendView.m
//  FrenchTV
//
//  Created by mac on 15/2/5.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "RecommendView.h"
#import "AppDelegate.h"
#import "RecomListViewController.h"


@implementation RecommendView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:gr];
        
        self.backgroundColor = MakeRgbColor(100, 100, 100, 1);
        self.image = [UIImage imageNamed:@"19"];
    }
    
    return self;
}


-(void)tap:(UIGestureRecognizer *)sender
{
    UINavigationController * nc = (UINavigationController *)[AppDelegate getTabbar].selectedViewController;
    RecomListViewController * rlvc = [RecomListViewController new];
    //rlvc应该有个id
    [nc pushViewController:rlvc animated:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
