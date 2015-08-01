//
//  TopicViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *topicTitle;
@property (weak, nonatomic) IBOutlet UILabel *topicDate;
@property (weak, nonatomic) IBOutlet UILabel *topicWriter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
