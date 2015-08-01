//
//  ClassAnswerCell.m
//  FrenchTV
//
//  Created by mac on 15/3/18.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ClassAnswerCell.h"
#import <MediaPlayer/MediaPlayer.h>



#define LabelFont [UIFont systemFontOfSize:15.0f]
#define BubbleMaxSize CGSizeMake(180.0f, 500.0f)

@implementation ClassAnswerCell

{
    UILabel *_label;
    UIButton * playVoice;
    MPMoviePlayerViewController * play;
}

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        if (isSender) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, self.bubbleView.frame.size.width-30.0f, self.bubbleView.frame.size.height-6.0f)];
            playVoice = [UIButton buttonWithType:UIButtonTypeCustom];
            playVoice.frame = CGRectMake(self.bubbleView.frame.size.width - 30, 10, 20, 20);
            [playVoice setBackgroundImage:[UIImage imageNamed:@"35"] forState:UIControlStateNormal];
            [playVoice addTarget:self action:@selector(playVoiceClick) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            _label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, self.bubbleView.frame.size.width-30.0f, self.bubbleView.frame.size.height-6.0f)];
            playVoice = [UIButton buttonWithType:UIButtonTypeCustom];
            playVoice.frame = CGRectMake(self.bubbleView.frame.size.width - 25, 10, 20, 20);
            [playVoice setBackgroundImage:[UIImage imageNamed:@"35"] forState:UIControlStateNormal];
            [playVoice addTarget:self action:@selector(playVoiceClick) forControlEvents:UIControlEventTouchUpInside];
            self.portraitImg.image = [UIImage imageNamed:@"20"];
        }
        _label.numberOfLines = 0;
        _label.font = LabelFont;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.bubbleView addSubview:_label];
        [self.bubbleView addSubview:playVoice];
    }
    return self;
}

-(void)playVoiceClick
{
    if(self.classMessage.videoUrl.length > 0)
    {
        if (play) {
            [play.moviePlayer play];
            return;
        }
        
        play=[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:self.classMessage.videoUrl]];
        
        
        [play.moviePlayer prepareToPlay];
        
        
        
        [play.moviePlayer play];
    }else
    {
        return;
    }
}

+(CGFloat)getHightOfCellViewWith:(ClassMessageModel *)message{
    CGFloat height = 65.0f;
    
    CGSize bubbleSize = [message.text sizeWithFont:LabelFont constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    if (bubbleSize.height>45.0f) {
        height = bubbleSize.height+20.0f;
    }
    return height;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    return;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _label.text = self.classMessage.text;
    CGSize bubbleSize = [self.classMessage.text sizeWithFont:LabelFont constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    if (bubbleSize.height<40.0f) {
        bubbleSize.height=40.0f;
    }
    
    if (self.isSender) {
        _label.frame = CGRectMake(9.0f, 2.0f, bubbleSize.width, bubbleSize.height);
        
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-bubbleSize.width-50.0f-10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+50.0f, bubbleSize.height+6.0f);
//        playVoice.frame = CGRectMake(self.bubbleView.frame.size.width - 30, 10, 20, 20);
        playVoice.hidden = YES;
    }
    else{
        playVoice.hidden = NO;
        _label.frame = CGRectMake(16.0f, 2.0f, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+self.portraitImg.frame.size.width+10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+50.0f, bubbleSize.height+6.0f);
        playVoice.frame = CGRectMake(self.bubbleView.frame.size.width - 30, 13, 20, 20);
    }
    
//    [super updateMessageSendStatus:self.displayMessage.messageState];
}


@end
