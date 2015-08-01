//
//  MainLoginViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *FacebookLogin;
- (IBAction)FacebookLoginClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *IntoLoginView;
- (IBAction)IntoLoginViewClick:(UIButton *)sender;

@end
