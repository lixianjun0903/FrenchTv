//
//  ChatViewTextCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ChatViewTextCell.h"
#import "ECTextMessageBody.h"


NSString *const KResponderCustomChatViewTextCellBubbleViewEvent = @"KResponderCustomChatViewTextCellBubbleViewEvent";

#define LabelFont [UIFont systemFontOfSize:15.0f]
#define BubbleMaxSize CGSizeMake(180.0f, 500.0f)

@implementation ChatViewTextCell
{
    UILabel *_label;
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        if (isSender) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-6.0f)];
        }
        else{
            _label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-6.0f)];
        }
        _label.numberOfLines = 0;
        _label.font = LabelFont;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.bubbleView addSubview:_label];
    }
    return self;
}

-(void)bubbleViewTapGesture:(id)sender{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    CGFloat height = 65.0f;
    ECTextMessageBody *body = (ECTextMessageBody*)message;
    CGSize bubbleSize = [body.text sizeWithFont:LabelFont constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    if (bubbleSize.height>45.0f) {
        height = bubbleSize.height+20.0f;
    }
    return height;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    ECTextMessageBody *body = (ECTextMessageBody*)self.displayMessage.messageBody;
    _label.text = body.text;
    CGSize bubbleSize = [body.text sizeWithFont:LabelFont constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    if (bubbleSize.height<40.0f) {
        bubbleSize.height=40.0f;
    }
    
    if (self.isSender) {
        _label.frame = CGRectMake(9.0f, 2.0f, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-bubbleSize.width-25.0f-10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+25.0f, bubbleSize.height+6.0f);
    }
    else{
        _label.frame = CGRectMake(16.0f, 2.0f, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+self.portraitImg.frame.size.width+10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+25.0f, bubbleSize.height+6.0f);
    }
    
    [super updateMessageSendStatus:self.displayMessage.messageState];
}
@end
