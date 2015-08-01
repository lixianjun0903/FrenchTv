//
//  JWLoginViewController.h
//  FrenchTV
//
//  Created by gaobo on 15/2/4.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *BGView;
@property (weak, nonatomic) IBOutlet UITextField *massageTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)regiestClick:(UIButton *)sender;

@end
