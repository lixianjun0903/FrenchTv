//
//  JWLoginViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWLoginViewController : UIViewController
- (IBAction)accountLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIView *BGView;

@end
