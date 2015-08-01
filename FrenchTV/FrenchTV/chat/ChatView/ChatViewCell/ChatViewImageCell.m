//
//  ChatViewImageCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/16.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewImageCell.h"
#import "UIImageView+WebCache.h"
#import "CommonTools.h"
#import "ECMediaMessageBody.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif

NSString *const KResponderCustomChatViewImageCellBubbleViewEvent = @"KResponderCustomChatViewImageCellBubbleViewEvent";

@implementation ChatViewImageCell
{
    UIImageView* _displayImage;
}

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(5, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-140.0f, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            
        }else{
            
            _displayImage.frame = CGRectMake(15, 5, 110.0f, 120.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 130.0f, 130.0f);
            
        }
        
        [self.bubbleView addSubview:_displayImage];
    
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewImageCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 150.0f;
}
-(void)getImageWithwidth:(CGFloat)width andgetImageWithhight:(CGFloat)hight
{
    CGFloat newWidth = 120*width/hight;
    
    if (self.isSender) {
        _displayImage.frame = CGRectMake(5, 5, newWidth, 120.0f);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-newWidth-30, self.portraitImg.frame.origin.y, newWidth+20, 130.0f);
        
    }else{
        _displayImage.frame = CGRectMake(15, 5, newWidth, 120.0f);
        
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, newWidth+20, 130.0f);
    }
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _displayImage.image = [UIImage imageNamed:@"chat_placeholder_image"];
    ECMessage *message = self.displayMessage;
    ECMediaMessageBody *mediaBody = (ECMediaMessageBody*)message.messageBody;
    if(message.messageState == ECMessageState_Receive && mediaBody.thumbnailRemotePath.length>0){
        [_displayImage sd_setImageWithURL:[NSURL URLWithString:mediaBody.thumbnailRemotePath] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            _displayImage.image = image;
            [self getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
        }];
    }
    
    else if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
        NSString * compressfilePath = [NSString stringWithFormat:@"%@.jpg_press", mediaBody.localPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:compressfilePath]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    UIImage * image = [UIImage imageWithContentsOfFile:compressfilePath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _displayImage.image = image;
                        
                        [self getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
                    });
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    UIImage * image = [UIImage imageWithContentsOfFile:mediaBody.localPath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _displayImage.image = image;
                        
                        [self getImageWithwidth:image.size.width andgetImageWithhight:image.size.height];
                    });
                }
            });
        }
    }
    [super updateMessageSendStatus:self.displayMessage.messageState];
}
@end
