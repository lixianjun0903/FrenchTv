//
//  HostChatVoiceViewController.h
//  FrenchTV
//
//  Created by mac on 15/3/24.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HostChatVoiceViewController : UIViewController
@property (strong,nonatomic)UITableViewCell * cell;
@property (assign)int viewTag;
-(instancetype)initWithSessionId:(NSString*)sessionId;
@end
