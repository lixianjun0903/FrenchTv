//
//  NoticeActivityCell.h
//  FrenchTV
//
//  Created by gaobo on 15/3/5.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticeCellModel.h"

@interface NoticeActivityCell : UITableViewCell

-(void)config:(NoticeCellModel *)mod;

@property (strong, nonatomic) void(^myblock)(void);

@end
