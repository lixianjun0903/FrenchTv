//
//  ClassChatViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/17.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ClassChatViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <MapKit/MapKit.h>
#import "ChatViewTextCell.h"
#import "ChatViewFileCell.h"
#import "ChatViewVoiceCell.h"
#import "ChatViewImageCell.h"
#import "ChatViewVideoCell.h"
#import "ClassAnswerCell.h"
#import "ECMessage.h"
#import "DemoGlobalClass.h"
#import "DeviceDelegateHelper.h"
#import "MBProgressHUD.h"
#import "MapViewController.h"
#import "MessageMapViewController.h"
#import "HostVideoCell.h"
#import "HostVoteCell.h"
#import "ClassMessageModel.h"
#import <MediaPlayer/MediaPlayer.h>


#import "HPGrowingTextView.h"
#import "CommonTools.h"

#import "MWPhotoBrowser.h"
#import "MWPhoto.h"

#import "CustomEmojiView.h"
#import "AccountRequest.h"

#define ToolbarInputViewHeight 43.0f
#define ToolbarMoreViewHeight 90.0f
#define ToolbarDefaultTotalHeigth 133.0f //ToolbarInputViewHeight+ToolbarEmojiViewHeight
#define MakeRgbColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

typedef enum {
    ToolbarDisplay_None=0,
    ToolbarDisplay_Emoji,
    ToolbarDisplay_More,
    ToolbarDisplay_Record
}ToolbarDisplay;

typedef enum {
    MedieMessageType_File = 0,
    MedieMessageType_Voice,
    MedieMessageType_Image,
    MedieMessageType_Video,
    MedieMessageType_Location
}MedieMessageType;

@interface ClassChatViewController ()<UITableViewDataSource, UITableViewDelegate,HPGrowingTextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomEmojiViewDelegate>
{
   
    dispatch_once_t emojiCreateOnce;
    NSIndexPath* _longPressIndexPath;
    UIMenuController*  _menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    CGFloat viewHeight;
    MPMoviePlayerViewController * play;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray* messageArray;
@property (nonatomic,strong) NSMutableArray * learningArray;
@property (nonatomic, strong) NSString* myVoip;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong,nonatomic)  NSDictionary * HostNewsDic;

#warning 录音效果页面
@property (nonatomic, strong) UIImageView *amplitudeImageView;
@property (nonatomic, strong) UILabel *recordInfoLabel;
@property (nonatomic, strong) ECMessage *playVoiceMessage;


@end

@implementation ClassChatViewController

{
#warning 切换工具栏显示
    UIView* _containerView;
    UIImageView *_inputMaskImage;
    HPGrowingTextView *_inputTextView;
    ToolbarDisplay toolbarDisplay;
    BOOL _isDisplayKeyborad;
    CGFloat _oldInputHeight;
    UIView* _inputView;
    UIButton *_recordBtn;
    
#warning 表情页面
    UIButton *_emojiBtn;
    UIButton *_switchVoiceBtn;
    UIButton *_moreBtn;
    CustomEmojiView *_emojiView;
    int nameNum;
    
}




-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self createLeftNav];
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    viewHeight = [UIScreen mainScreen].bounds.size.height-64.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endOperation)];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    self.messageArray = [NSMutableArray array];
    
    self.learningArray = [NSMutableArray arrayWithCapacity:0];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width,self.view.frame.size.height-ToolbarInputViewHeight-64.0f) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = MakeRgbColor(246, 246, 246, 1);
    [self.tableView addGestureRecognizer:tap];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.myVoip = [DemoGlobalClass sharedInstance].loginInfo.account;
    
    
    
    
    
    [self createToolBarView];
    
    self.amplitudeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"press_speak_icon_07"]];
    _amplitudeImageView.center = self.view.center;
    self.recordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, _amplitudeImageView.frame.size.height-40.0f, _amplitudeImageView.frame.size.width, 30.0f)];
    _recordInfoLabel.backgroundColor = [UIColor clearColor];
    _recordInfoLabel.textAlignment = NSTextAlignmentCenter;
    _recordInfoLabel.textColor = [UIColor whiteColor];
    _recordInfoLabel.font = [UIFont systemFontOfSize:13.0f];
    
    [_amplitudeImageView addSubview:_recordInfoLabel];
    [self.view addSubview:_amplitudeImageView];
    [self.view sendSubviewToBack:_amplitudeImageView];
    
    [self reLoadTableView:nil];
}

-(void)createLeftNav
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 10, 20);
    [button setImage:[UIImage imageNamed:@"17"] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


//view出现时触发
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoadTableView:) name:@"ClassMessageChange" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

}

//view出现后触发
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //    extern NSString *const Notification_ChangeMainDisplay;
    //    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ChangeMainDisplay object:@0];
    
    dispatch_once(&emojiCreateOnce, ^{
        _emojiView = [CustomEmojiView shardInstance];
        _emojiView.delegate = self;
        _emojiView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.0f);
        
        if (_emojiView.superview == nil) {
            [self.view addSubview:_emojiView];
        }
    });
    
//    [[DeviceDBHelper sharedInstance].msgDBAccess markMessagesAsReadOfSession:self.sessionId];
}

//view消失时触发
-(void)viewWillDisappear:(BOOL)animated
{
    [_inputTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_onRecordingAmplitude object:nil];
    
    if (self.playVoiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    }
    self.playVoiceMessage = nil;
    
//    [[DeviceDBHelper sharedInstance].msgDBAccess markMessagesAsReadOfSession:self.sessionId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
    
    
    [super viewWillDisappear:animated];
}

-(void)movieFinish{
    NSLog(@"1111");
    [play.view removeFromSuperview];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - private method


//返回上一层
-(void)popViewController:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showMenuViewController:(UIView *)showInView messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == MessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

#pragma mark - notification method


-(void)reLoadTableView:(NSNotification*)notification{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (notification == nil || notification.object == nil) {
        [self.tableView reloadData];
    }
    if (self.learningArray.count>0){
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.learningArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

/**
 *@brief 键盘的frame更改监听函数
 */
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat frameY = self.view.frame.size.height-ToolbarInputViewHeight;
    CGRect frame = _containerView.frame;
    
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height){
        //显示键盘
        toolbarDisplay = ToolbarDisplay_None;
        _isDisplayKeyborad = YES;
        
        //只显示输入view
        frameY = endFrame.origin.y-_containerView.frame.size.height+ToolbarMoreViewHeight;
    }
    else if (endFrame.origin.y == [[UIScreen mainScreen] bounds].size.height){
        //隐藏键盘
        _isDisplayKeyborad = NO;
        
        //根据不同的类型显示toolbar
        switch (toolbarDisplay) {
            case ToolbarDisplay_Emoji:
            {
                frameY = endFrame.origin.y-frame.size.height-126.0f;
                void(^animations)() = ^{
                    CGRect frame = _emojiView.frame;
                    frame.origin.y = viewHeight-_emojiView.frame.size.height;
                    _emojiView.frame=frame;
                };
                [UIView animateWithDuration:0.25 delay:0.1f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
            }
                break;
                
            case ToolbarDisplay_Record:
                frameY = endFrame.origin.y-frame.size.height+ToolbarMoreViewHeight;
                break;
                
            case ToolbarDisplay_More:
                frameY = endFrame.origin.y-frame.size.height;
                break;
                
            default:
                frameY = endFrame.origin.y-frame.size.height+ToolbarMoreViewHeight;
                break;
        }
    }
    else{
        frameY = endFrame.origin.y-frame.size.height+ToolbarMoreViewHeight;
    }
    
    frameY -= 64.0f;
    [self toolbarDisplayChangedToFrameY:frameY andDuration:duration];
    
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClassMessageModel *message = [self.learningArray objectAtIndex:indexPath.row];
    CGFloat height = [ClassAnswerCell getHightOfCellViewWith:message];
#warning 显示的时间高度为30.0f
    return height;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.learningArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClassMessageModel *message = [self.learningArray objectAtIndex:indexPath.row];
    
    
    NSString *cellidentifier ;
    if(message.isSender)
    {
        cellidentifier = @"issender";
    }else
    {
        cellidentifier = @"isreceive";
    }
    
    ClassAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    if(!cell)
    {
        cell = [[ClassAnswerCell alloc] initWithIsSender:message.isSender reuseIdentifier:cellidentifier];
        
    }
    cell.classMessage = message;
    
//    if (cell == nil) {
//        switch (message.messageBody.messageBodyType) {
//                
//            case MessageBodyType_Text:
//                cell = [[ChatViewTextCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                break;
//            case MessageBodyType_Media:
//            {
//                if (fileType == MedieMessageType_Voice)
//                {
//                    cell = [[ChatViewVoiceCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                }
//                if (fileType == MedieMessageType_Image)
//                {
//                    cell = [[ChatViewImageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                }
//                if(fileType == MedieMessageType_Location)
//                {
//                    cell = [[ChatViewImageCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                }
//                if (fileType == MedieMessageType_Video)
//                {
//                    cell = [[ChatViewVideoCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                }
//                if(fileType == MedieMessageType_File)
//                {
//                    cell = [[ChatViewFileCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                }
//            }
//                break;
//                
//            case MessageBodyType_ChunkVoice:
//                cell =[[ChatViewVoiceCell alloc] initWithIsSender:isSender reuseIdentifier:cellidentifier];
//                break;
//                
//            default:
//                break;
//        }
    
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHandleLongPress:)];
//        [cell.bubbleView addGestureRecognizer:longPress];
//  
//    
//    [cell bubbleViewWithData:[self.learningArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - GestureRecognizer

//点击tableview，结束输入操作
-(void)endOperation{
    if (toolbarDisplay == ToolbarDisplay_Record) {
        return;
    }
    toolbarDisplay = ToolbarDisplay_None;
    if (_isDisplayKeyborad) {
        [self.view endEditing:YES];
    }
    else{
        [self toolbarDisplayChangedToFrameY:viewHeight-_containerView.frame.size.height+ToolbarMoreViewHeight andDuration:0.25];
    }
}

-(void)cellHandleLongPress:(UILongPressGestureRecognizer * )longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return;
        
        ChatViewCell *cell = (ChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        _longPressIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView messageType:cell.displayMessage.messageBody.messageBodyType];
    }
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    //复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row < self.messageArray.count) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        ECTextMessageBody *body = (ECTextMessageBody*)message.messageBody;
        pasteboard.string = body.text;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        ECMessage *message = [self.messageArray objectAtIndex:_longPressIndexPath.row];
        [[DeviceDBHelper sharedInstance].msgDBAccess deleteMessage:message.messageId];
        [self.messageArray removeObject:message];
        [self.tableView deleteRowsAtIndexPaths:@[_longPressIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _longPressIndexPath = nil;
}




#pragma mark - 创建工具栏和布局变化操作

/**
 *@brief 生成工具栏
 */
-(void)createToolBarView{
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.view.frame.size.width, ToolbarDefaultTotalHeigth)];
    _containerView.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    [self.view addSubview:_containerView];
    _oldInputHeight = ToolbarDefaultTotalHeigth;
    
    //聊天的基础功能
    _switchVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchVoiceBtn.tag = ToolbarDisplay_Record;
    [_switchVoiceBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_switchVoiceBtn setImage:[UIImage imageNamed:@"42"] forState:UIControlStateNormal];
    [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
    _switchVoiceBtn.frame = CGRectMake(5.0f, 5.0f, 31.0f, 31.0f);
    _switchVoiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _containerView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    [_containerView addSubview:_switchVoiceBtn];
    
    _inputTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(40.0f, 7.0f, 183.0f, 25.0f)];
    _inputTextView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 3, 5);
    _inputTextView.minNumberOfLines = 1;
    _inputTextView.maxNumberOfLines = 4;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:16.0f];
    _inputTextView.delegate = self;
    //    _inputTextView.placeholder = @"添加文本";
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _inputMaskImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"input_box"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f]];
    _inputMaskImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _inputMaskImage.center = _inputTextView.center;
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_moreBtn setImage:[UIImage imageNamed:@"38"] forState:UIControlStateNormal];
    [_moreBtn setImage:[UIImage imageNamed:@"add_icon_on"] forState:UIControlStateHighlighted];
    _moreBtn.frame = CGRectMake(_containerView.frame.size.width-36.0f, 5.0f, 31.0f, 31.0f);
    _moreBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _moreBtn.tag = ToolbarDisplay_More;
    [_containerView addSubview:_moreBtn];
    
    _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _emojiBtn.tag = ToolbarDisplay_Emoji;
//    [_emojiBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
    [_emojiBtn setImage:[UIImage imageNamed:@"37"] forState:UIControlStateNormal];
    [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    _emojiBtn.frame = CGRectMake(_moreBtn.frame.origin.x-36.0f, 5.0f, 31.0f, 31.0f);
    _emojiBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_containerView addSubview:_emojiBtn];
    
    CGFloat frame_x = _switchVoiceBtn.frame.origin.x+_switchVoiceBtn.frame.size.width+5.0f;
    _inputTextView.frame = CGRectMake(0, 7.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 25.0f);
    _inputMaskImage.frame = CGRectMake(0, 5.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 31.0f);
    _inputView = [[UIView alloc] initWithFrame:CGRectMake(frame_x, 0.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 43.0f)];
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_inputView addSubview:_inputTextView];
    [_inputView addSubview:_inputMaskImage];
    [_containerView addSubview:_inputView];
    
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"voice_record"] forState:UIControlStateNormal];
    [_recordBtn setTitle:@"Presse.." forState:UIControlStateNormal];
    _recordBtn.frame = CGRectMake(frame_x, 5.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 31.0f);
    [_containerView addSubview:_recordBtn];
//    [_recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
//    [_recordBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
//    [_recordBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//    [_recordBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
//    [_recordBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
    _recordBtn.hidden = YES;
    
    
    //更多的附加功能
    [self createMoreView];
}

-(void)createMoreView{
    
    UIView *moreView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, ToolbarInputViewHeight, _containerView.frame.size.width, ToolbarMoreViewHeight)];
    moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    moreView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [_containerView addSubview:moreView];
    
#ifdef Support_Video_Send
    NSArray *imagesArr = @[@"dialogue_image_icon",@"dialogue_camera_icon",@"dialogue_image_icon"];
    NSArray *textArr = @[@"图片",@"照相",@"视频"];
    NSArray *selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"videoBtnTap:"];
#else
    NSArray *imagesArr = @[@"39",@"40",@"41"];
    //NSArray *textArr = @[@"图片",@"照相"];
    NSArray *selectorArr = @[@"pictureBtnTap:",@"cameraBtnTap:",@"GPSTap:"];
#endif
    
    for (NSInteger index = 0; index<imagesArr.count; index++) {
        NSString *imageLight = [NSString stringWithFormat:@"%@_on",imagesArr[index]];
        UIButton *extenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        SEL selector = NSSelectorFromString(selectorArr[index]);
        [extenBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [extenBtn setImage:[UIImage imageNamed:imagesArr[index]] forState:UIControlStateNormal];
        [extenBtn setImage:[UIImage imageNamed:imageLight] forState:UIControlStateHighlighted];
        extenBtn.frame = CGRectMake(25.0f+80.0f*index, 10.0f, 50.0f, 50.0f);
        [moreView addSubview:extenBtn];
        
        //        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(extenBtn.frame.origin.x, extenBtn.frame.origin.y+extenBtn.frame.size.height+5.0f, extenBtn.frame.size.width, 15.0f)];
        //        btnLabel.font = [UIFont systemFontOfSize:15.0f];
        //        btnLabel.textAlignment = NSTextAlignmentCenter;
        //        [moreView addSubview:btnLabel];
        //        btnLabel.text = textArr[index];
    }
}

-(void)GPSTap:(UIButton *)sender
{
    ECNoTitleAlert(@"中文课堂下无法发送位置");
}

#pragma mark - CustomEmojiViewDelegate
-(void)emojiBtnInput:(NSInteger)emojiTag{
    _inputTextView.text =  [_inputTextView.text stringByAppendingString:
                            [CommonTools getExpressionStrById:emojiTag]];
    
}

-(void)backspaceText{
    if(_inputTextView.text.length > 0)
    {
        [_inputTextView deleteBackward];
    }
}

-(void)emojiSendBtn:(id)sender{
    [self sendTextMessage];
    _inputTextView.text = @"";
}
/**
 *@brief 改变toolbar显示的frame Y值
 */
-(void)toolbarDisplayChangedToFrameY:(CGFloat)frame_y andDuration:(NSTimeInterval)duration{
    
    if (toolbarDisplay == ToolbarDisplay_None) {
        [_emojiBtn setImage:[UIImage imageNamed:@"37"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame = frame;
    }
    
    //如果只显示的toolbar是输入框，表情页消失
    if (frame_y == self.view.frame.size.height-_containerView.frame.size.height+ToolbarMoreViewHeight) {
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame = frame;
    }
    
    void(^animations)() = ^{
        CGRect frame = _containerView.frame;
        frame.origin.y = frame_y;
        _containerView.frame = frame;
        frame = self.tableView.frame;
        frame.size.height = _containerView.frame.origin.y-self.tableView.frame.origin.y;
        self.tableView.frame = frame;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        if (self.learningArray.count>0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}



#pragma mark - 录音操作



#pragma mark - moreview 动作

/**
 *@brief 图片按钮
 */
-(void)pictureBtnTap:(id)sender{
    
    [self endOperation];
    
    ECNoTitleAlert(@"中文课堂下无法发送图片");
}

/**
 *@brief 照相按钮
 */
-(void)cameraBtnTap:(id)sender{
    
    [self endOperation];
    
    ECNoTitleAlert(@"中文课堂下无法发送图片");
}

#pragma mark - 发送消息操作


/**
 *@brief 发送文本消息
 */
-(void)sendTextMessage{
    
    NSString * textString = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textString.length == 0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"不能发送空白消息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    ClassMessageModel * message = [[ClassMessageModel alloc] init];
    
    message.text = textString;
    message.isSender = YES;
    [self.learningArray addObject:message];
    
    [AccountRequest LessonSendWord:textString withSucc:^(NSDictionary * dataDic) {
        
        ClassMessageModel * recevieMessage = [[ClassMessageModel alloc] init];
        
        recevieMessage.text = dataDic[@"content"];
        
        recevieMessage.isSender = NO;
        
        if([dataDic[@"url"] length] > 0)
        {
            recevieMessage.videoUrl = dataDic[@"url"];
        }
        
        [self.learningArray addObject:recevieMessage];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassMessageChange" object:message];
    }];
    

}




#pragma mark - HPGrowingTextViewDelegate

//根据新的高度来改变当前的页面的的布局
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    void(^animations)() = ^{
        CGRect r = _containerView.frame;
        r.size.height -= diff;
        r.origin.y += diff;
        _containerView.frame = r;
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height += diff;
        self.tableView.frame = tableFrame;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        if (self.learningArray.count>0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.learningArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    [UIView animateWithDuration:0.1 delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self sendTextMessage];
        growingTextView.text = @"";
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    if (range.length == 1) {
        return YES;
    }
    
#warning 文本发送内容最多为2000字节
    if ( ([text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + [_inputTextView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) >= 2001)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"内容最多为2000字节" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
        return NO;
    }
    return YES;
}

//获取焦点
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    _inputMaskImage.image = [[UIImage imageNamed:@"input_box_on"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f];
}

//失去焦点
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    _inputMaskImage.image = [[UIImage imageNamed:@"input_box"] stretchableImageWithLeftCapWidth:95.0f topCapHeight:16.0f];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
