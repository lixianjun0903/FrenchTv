//
//  ChangePassViewController.h
//  FrenchTV
//
//  Created by gaobo on 15/3/27.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePassViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *oldWord;
@property (weak, nonatomic) IBOutlet UITextField *word_new1;
@property (weak, nonatomic) IBOutlet UITextField *word_new2;

- (IBAction)changeClick:(UIButton *)sender;

@end
