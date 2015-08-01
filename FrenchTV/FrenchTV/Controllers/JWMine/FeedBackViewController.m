//
//  FeedBackViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()
@property (weak, nonatomic) IBOutlet UITextView *_textView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumField;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    [self createUI];
}
- (IBAction)feedClick:(id)sender
{
    [AccountRequest accountFeedBackWithText:self._textView.text withMail:self.emailField.text withPhoneNum:self.phoneNumField.text withSucc:^(NSDictionary *dic) {
        //反馈成功
        [MBProgressHUD creatembHub:@"Le succès de rétroaction"];
        [[AppDelegate getNav] popViewControllerAnimated:YES];
        
        
    }];
    
}

-(void)createUI
{
    self._textView.layer.cornerRadius = 3;
    self._textView.layer.borderWidth = 0.3;
    self._textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self._textView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self._textView resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.phoneNumField resignFirstResponder];
}


@end
