//
//  ChatViewVideoCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 14/12/30.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewVideoCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ECMediaMessageBody.h"
NSString *const KResponderCustomChatViewVideoCellBubbleViewEvent = @"KResponderCustomChatViewVideoCellBubbleViewEvent";
@implementation ChatViewVideoCell
{
    UIImageView* _displayImage;
    UIButton * _playBtn;
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        _playBtn = [[UIButton alloc]init];
        _playBtn.alpha = 0.7;
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"playerStart.png"] forState:UIControlStateNormal];
        
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(5, 5, 200.0f, 150.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-230, self.portraitImg.frame.origin.y-5, 220.0f, 160.0f);
            
        }else{
            
            _displayImage.frame = CGRectMake(15, 5, 200.0f, 150.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 220.0f, 160.0f);

        }
        
        _playBtn.frame = CGRectMake(_displayImage.frame.origin.x+77.0f, _displayImage.frame.origin.y+52.0f, 45.0f, 45.0f);
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_playBtn];
    }
    return self;
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 180.0f;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    ECMessage *message = self.displayMessage;
    ECMediaMessageBody *mediaBody = (ECMediaMessageBody*)message.messageBody;
    
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath])
    {
        UIImage * videoImage = [self getVideoImage:[mediaBody.localPath copy]];
        
        if (videoImage)
        {
            _displayImage.image = videoImage;
        }
    }
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
}


-(void)bubbleViewTapGesture:(id)sender{
    
}


-(void)playVideo
{
    [self dispatchCustomEventWithName:KResponderCustomChatViewVideoCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage * returnImage = [[UIImage alloc] initWithContentsOfFile:imagePath] ;
    if (returnImage)
    {
        return returnImage;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil] ;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    returnImage = [[UIImage alloc] initWithCGImage:image] ;
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    return returnImage;
}
@end
