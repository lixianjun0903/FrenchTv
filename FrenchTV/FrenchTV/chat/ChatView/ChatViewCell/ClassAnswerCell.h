//
//  ClassAnswerCell.h
//  FrenchTV
//
//  Created by mac on 15/3/18.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ChatViewCell.h"
#import "ClassMessageModel.h"

@interface ClassAnswerCell : ChatViewCell
@property (strong,nonatomic)  ClassMessageModel * classMessage;
+(CGFloat)getHightOfCellViewWith:(ClassMessageModel *)message;
@end
