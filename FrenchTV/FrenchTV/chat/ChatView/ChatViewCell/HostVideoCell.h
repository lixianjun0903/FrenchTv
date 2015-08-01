//
//  HostVideoCell.h
//  FrenchTV
//
//  Created by mac on 15/3/12.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ChatViewCell.h"

@interface HostVideoCell : ChatViewCell
@property (strong,nonatomic) void(^playBlock)(NSString * videoUrl);
-(void)config:(NSDictionary *)dataDic;
@end
