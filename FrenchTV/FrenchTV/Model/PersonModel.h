//
//  PersonModel.h
//  FrenchTV
//
//  Created by mac on 15/3/4.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonModel : NSObject

@property (strong,nonatomic)NSString * userId;
@property (strong,nonatomic)NSString * realname;
@property (strong,nonatomic)NSString * disabled;
@property (strong,nonatomic)NSString * userImg;
@property (strong,nonatomic)NSString * subAccountId;
@property (strong,nonatomic)NSString * subToken;
@property (strong,nonatomic)NSString * voipAccount;
@property (strong,nonatomic)NSString * voipPassword;


@end
