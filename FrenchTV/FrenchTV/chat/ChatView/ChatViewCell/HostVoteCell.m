//
//  HostVoteCell.m
//  FrenchTV
//
//  Created by mac on 15/3/13.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "HostVoteCell.h"

@implementation HostVoteCell

{
    UIImageView* _displayImage;
    
    UILabel * _VoteTitle;
    
    UIImageView * hostDefaultImage;
    
    UILabel * hostName;
    
    UILabel * content;
    
    //图片下面4个button
    UIButton * commit;
    
    UIButton * selectButton;
    
    int topicId;
    
    NSMutableArray * itemArray;
    
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        [_displayImage setImage:[UIImage imageNamed:@"30"]];
        
        _VoteTitle = [[UILabel alloc] init];
        _VoteTitle.textColor = [UIColor blackColor];
        _VoteTitle.text = @"Fresh Apricot With Huge Sale";
        _VoteTitle.textColor = MakeRgbColor(219, 95, 111, 1);
        _VoteTitle.font = [UIFont boldSystemFontOfSize:6];
        _VoteTitle.numberOfLines = 0;
        
        hostDefaultImage = [[UIImageView alloc] init];
        hostDefaultImage.image = [UIImage imageNamed:@"15"];
        hostDefaultImage.contentMode = UIViewContentModeScaleAspectFill;
        hostDefaultImage.clipsToBounds = YES;
        
        hostName = [[UILabel alloc] init];
        hostName.text = @"M-FirN";
        hostName.textColor = [UIColor lightGrayColor];
        hostName.font = [UIFont systemFontOfSize:5];
        
        content = [[UILabel alloc] init];
        content.text = @"J’aime les longues vacances auxquelles les professeurs ont droit. Quand les vacances s’approchent, je commence à faire des projets. Quelquefois, je fait un voyage dans d’autres parties du pays. Je demande à  mon ami de m’accueillir et de m’accompagner voir de splendides vues vacance D’ailleurs, il est bon que je puisse faire des courses sans me presser pendant les vacances.";
        content.textColor = [UIColor grayColor];
        content.font = [UIFont systemFontOfSize:6];
        content.numberOfLines = 0;
        
        commit = [UIButton buttonWithType:UIButtonTypeCustom];
        [commit setBackgroundImage:[UIImage imageNamed:@"56"] forState:UIControlStateNormal];
        [commit addTarget:self action:@selector(commitVote:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        if (self.isSender) {
            
            _displayImage.frame = CGRectMake(10, 10, 85, 85);
            _VoteTitle.frame = CGRectMake(100, 5, 100, 10);
            hostDefaultImage.frame = CGRectMake(100, 20, 7, 7);
            hostName.frame = CGRectMake(109, 20, 100, 6);
            content.frame = CGRectMake(100, 30, 100, 45);
            commit.frame = CGRectMake(100, 78, 40, 15);
            
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-230, self.portraitImg.frame.origin.y-5, 210, 150);

            
        }else{
            
            _displayImage.frame = CGRectMake(10, 10, 85, 85);
            _VoteTitle.frame = CGRectMake(100, 5, 100, 10);
            hostDefaultImage.frame = CGRectMake(100, 20, 7, 7);
            hostName.frame = CGRectMake(109, 20, 100, 6);
            content.frame = CGRectMake(100, 30, 100, 45);
            commit.frame = CGRectMake(100, 78, 40, 15);

            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 200.0f, 150);
            
        }
        
        
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_VoteTitle];
        [self.bubbleView addSubview:hostDefaultImage];
        [self.bubbleView addSubview:hostName];
        [self.bubbleView addSubview:content];
        [self.bubbleView addSubview:commit];
        
    }
    return self;
}

-(void)commitVote:(UIButton *)sender
{
    if(selectButton.tag - 100 > 4 || selectButton.tag - 100 < 0)
    {
        ECNoTitleAlert(@"请选择投票项");
        return;
    }
    int itemId = [itemArray[selectButton.tag - 100][@"itemId"] intValue];
    [AccountRequest commitHostVote:^(NSDictionary * stateDic) {
        if(stateDic[@"status"] == 0)
        {
            [MBProgressHUD creatembHub:stateDic[@"message"]];
        }else
        {
            ECNoTitleAlert(stateDic[@"message"]);
        }
    } WithTopicId:topicId WithitemID:itemId WithHostId:[[DemoGlobalClass sharedInstance].userInfoDic[@"userId"] intValue]];
}

-(void)config:(NSDictionary *)dataDic
{
    if(!dataDic)
    {
        return;
    }
    _VoteTitle.text = dataDic[@"title"];
    content.text = dataDic[@"description"];
    [_displayImage sd_setImageWithURL:[NSURL URLWithString:dataDic[@"img"]]];
    topicId = [dataDic[@"topicId"] intValue];
    
    if(dataDic[@"items"])
    {
        NSMutableArray * buttonNameArray = [NSMutableArray arrayWithArray:dataDic[@"items"]];
        itemArray = [NSMutableArray arrayWithArray:buttonNameArray];
        for(int i = 0 ; i < buttonNameArray.count;i++)
        {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:buttonNameArray[i][@"itemTitle"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            button.tag = 100 + i;
            [button addTarget:self action:@selector(voteSelect:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = MakeRgbColor(237, 238, 244, 1);
            button.frame = CGRectMake(10 + i * 48, 98, 40, 40);
            [self.bubbleView addSubview:button];
        }
    }
    
}

-(void)bubbleViewTapGesture:(id)sender{
    
    return;
}

-(void)voteSelect:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            sender.selected = !sender.selected;
            if(sender.selected)
            {
               selectButton = sender;
            }else
            {
                selectButton = nil;
            }
            
            for(UIButton * v in self.bubbleView.subviews){
                switch (v.tag) {
                    case 101:
                        v.selected = NO;
                        break;
                    case 102:
                        v.selected = NO;
                        break;
                    case 103:
                        v.selected = NO;
                        break;
                    default:
                        break;
                }
                
            }
        }
            break;
        case 101:
        {
            sender.selected = !sender.selected;
            if(sender.selected)
            {
                selectButton = sender;
            }else
            {
                selectButton = nil;
            }
            for(UIButton * v in self.bubbleView.subviews){
                switch (v.tag) {
                    case 100:
                        v.selected = NO;
                        break;
                    case 102:
                        v.selected = NO;
                        break;
                    case 103:
                        v.selected = NO;
                        break;
                    default:
                        break;
                }
                
            }
        }
            break;
        case 102:
        {
            sender.selected = !sender.selected;
            if(sender.selected)
            {
                selectButton = sender;
            }else
            {
                selectButton = nil;
            }
            for(UIButton * v in self.bubbleView.subviews){
                switch (v.tag) {
                    case 100:
                        v.selected = NO;
                        break;
                    case 101:
                        v.selected = NO;
                        break;
                    case 103:
                        v.selected = NO;
                        break;
                    default:
                        break;
                }
                
            }
        }
            break;
        case 103:
        {
            sender.selected = !sender.selected;
            if(sender.selected)
            {
                selectButton = sender;
            }else
            {
                selectButton = nil;
            }
            for(UIButton * v in self.bubbleView.subviews){
                switch (v.tag) {
                    case 100:
                        v.selected = NO;
                        break;
                    case 102:
                        v.selected = NO;
                        break;
                    case 101:
                        v.selected = NO;
                        break;
                    default:
                        break;
                }
                
            }
        }
            break;
        default:
            break;
    }
}



@end
