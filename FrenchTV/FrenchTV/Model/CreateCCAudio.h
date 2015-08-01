//
//  CreateMPMoviePlayer.h
//  FrenchTV
//
//  Created by gaobo on 15/3/30.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAudioPlayer.h"

@interface CreateCCAudio : NSObject
+(CCAudioPlayer *)sharedManager:(NSString *)musicUrl;
+(void)setPlayNil;
@end
