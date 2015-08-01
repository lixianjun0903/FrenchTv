//
//  CreateMPMoviePlayer.m
//  FrenchTV
//
//  Created by gaobo on 15/3/30.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "CreateCCAudio.h"


static CCAudioPlayer * play;

@implementation CreateCCAudio

+(CCAudioPlayer *)sharedManager:(NSString *)musicUrl
{
    
        if(play == nil)
        {
            play =[[CCAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:musicUrl]];
            return play;
        }
    
    
    return nil;
}

+(void)setPlayNil
{
    [play dispose];
    play = nil;

}


@end
