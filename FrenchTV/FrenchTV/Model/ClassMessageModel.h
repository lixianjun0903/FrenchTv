//
//  ClassMessageModel.h
//  FrenchTV
//
//  Created by mac on 15/3/18.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassMessageModel : NSObject
@property (strong,nonatomic) NSString * text;
@property (assign) BOOL isSender;
@property (strong,nonatomic) NSString * videoUrl;

@end
