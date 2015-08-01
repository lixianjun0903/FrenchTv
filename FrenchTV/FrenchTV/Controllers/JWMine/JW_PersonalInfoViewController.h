//
//  JW_PersonalInfoViewController.h
//  FrenchTV
//
//  Created by mac on 15/2/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

@interface JW_PersonalInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (weak, nonatomic) IBOutlet UIView *setView;
@property (weak, nonatomic) IBOutlet UIView *MessageView;
@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UIView *introduceView;
@property (weak, nonatomic) IBOutlet UIView *favoriteView;
@property (weak, nonatomic) IBOutlet UILabel *deleteView;

@end
