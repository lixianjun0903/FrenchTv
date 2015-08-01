//
//  ActivityViewController.h
//  FrenchTV
//
//  Created by gaobo on 15/2/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "NoticeCellModel.h"

typedef NS_ENUM(NSInteger, ActivityState) {
    ActivityNone = 0,
    ActivityWillBegin,
    ActivityIsBegining,
    ActivityIsOver
};

@interface ActivityViewController : UIViewController

@property (strong, nonatomic) NoticeCellModel * dataModel;

-(id)init;
-(id)initWithActivityState:(ActivityState)aState;
@end
