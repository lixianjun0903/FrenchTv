//
//  ChatViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController
@property (strong,nonatomic)UITableViewCell * cell;
@property (assign)int viewTag;
-(instancetype)initWithSessionId:(NSString*)sessionId;
@end
