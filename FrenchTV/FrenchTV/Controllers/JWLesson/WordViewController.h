//
//  WordViewController.h
//  FrenchTV
//
//  Created by gaobo on 15/3/14.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordViewController : UIViewController
- (IBAction)audioClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *oldText;

@property (weak, nonatomic) IBOutlet UITextView *fanText;
- (IBAction)sendBtn:(id)sender;

@end
