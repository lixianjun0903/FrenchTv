//
//  ChangePassViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/27.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ChangePassViewController.h"

@interface ChangePassViewController ()

@end

@implementation ChangePassViewController
@synthesize oldWord;
@synthesize word_new1;
@synthesize word_new2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [oldWord resignFirstResponder];
    [word_new1 resignFirstResponder];
    [word_new2 resignFirstResponder];
}


- (IBAction)changeClick:(UIButton *)sender {
    
    [oldWord resignFirstResponder];
    [word_new1 resignFirstResponder];
    [word_new2 resignFirstResponder];
    
    if ([oldWord.text isEqualToString:@""]) {
        [MBProgressHUD creatembHub:@"Erreur de mot de passe"];
        return;
    }
    if (![word_new1.text isEqualToString:word_new2.text])
    {
        [MBProgressHUD creatembHub:@"Deux fois le mot de passe différent"];
        return;
    }
    
    if ([word_new1.text isEqualToString:@" "]) {
        
        [MBProgressHUD creatembHub:@"Nouvelle entrée"];
        return;
    }
    
    [AccountRequest accountChangePasswordWithOld:oldWord.text withNew:word_new1.text withSucc:^(NSDictionary *dic) {
        
        [MBProgressHUD creatembHub:@"succes"];
        
    }];
    
    
}
@end
