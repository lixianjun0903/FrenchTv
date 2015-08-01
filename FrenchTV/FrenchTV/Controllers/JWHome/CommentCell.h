//
//  CommentCell.h
//  FrenchTV
//
//  Created by gaobo on 15/3/27.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLab;

-(void)config:(NSDictionary *)dic;
@property (weak, nonatomic) IBOutlet UILabel *commentLab;

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@end
