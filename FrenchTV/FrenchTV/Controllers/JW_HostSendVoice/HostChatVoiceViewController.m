//
//  HostChatVoiceViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/24.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "HostChatVoiceViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <MapKit/MapKit.h>

#import "ChatViewController.h"
#import "ChatViewTextCell.h"
#import "ChatViewFileCell.h"
#import "ChatViewVoiceCell.h"
#import "ChatViewImageCell.h"
#import "ChatViewVideoCell.h"
#import "ECMessage.h"
#import "DemoGlobalClass.h"
#import "DeviceDelegateHelper.h"
#import "MBProgressHUD.h"
#import "MapViewController.h"
#import "MessageMapViewController.h"
#import "HostVideoCell.h"
#import "HostVoteCell.h"
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
#warning 是否支持视频文件发送
//#define Support_Video_Send

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

@interface HostChatVoiceViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomEmojiViewDelegate>
{
    BOOL isGroup;
    dispatch_once_t emojiCreateOnce;
    NSIndexPath* _longPressIndexPath;
    UIMenuController*  _menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    CGFloat viewHeight;
    MPMoviePlayerViewController * play;
    BOOL isDownLoad;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, strong) NSMutableArray* messageArray;
@property (nonatomic, strong) NSString* myVoip;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong,nonatomic)  NSDictionary * HostNewsDic;

#warning 录音效果页面
@property (nonatomic, strong) UIImageView *amplitudeImageView;
@property (nonatomic, strong) UILabel *recordInfoLabel;
@property (nonatomic, strong) ECMessage *playVoiceMessage;
@property (nonatomic,strong) ECMessage * hostVoiceMessage;
@property (nonatomic,strong) NSString * hostVoiceFile;
@property (nonatomic,strong) NSString * hostVoiceFileDisplayName;
@end

@implementation HostChatVoiceViewController

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

- (instancetype)init
{
    NSAssert(NO, @"ChatViewController: use +initWithSessionId");
    return nil;
}

-(instancetype)initWithSessionId:(NSString*)aSessionId
{
    if (self = [super init]) {
        self.sessionId = aSessionId;
        //        isGroup = [aSessionId hasPrefix:@"g"];
    }
    return self;
}

-(void)loadData
{
    int hostId = [[DemoGlobalClass sharedInstance].userInfoDic[@"userId"] intValue];
    [AccountRequest getHostNews:^(NSDictionary *HostNews) {
        self.HostNewsDic = HostNews;
        if(![self fileExists])
        {
            if(isDownLoad)
            {
                return ;
            }
           isDownLoad = [AccountRequest downLoadFileWithUrl:self.HostNewsDic[@"voice"][@"voiceUrl"] withSucc:^(ECMediaMessageBody * messageBody) {
                
                self.hostVoiceMessage = [[ECMessage alloc] initWithReceiver:nil body:messageBody];
               isDownLoad = NO;
                [self.tableView reloadData];
            }];
        }else
        {	
            ECMediaMessageBody * mediaBody = [[ECMediaMessageBody alloc] initWithFile:self.hostVoiceFile displayName:self.hostVoiceFileDisplayName];
            self.hostVoiceMessage = [[ECMessage alloc] initWithReceiver:nil body:mediaBody];
            [self.tableView reloadData];
        }
        
    } WithHostId:hostId];
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH,SCREEN_HEIGHT-ToolbarInputViewHeight-64.0f) style:UITableViewStylePlain];
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
    
    [self refreshTableView:nil];
}

-(void)createLeftNav
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 15, 25);
    [button setBackgroundImage:[UIImage imageNamed:@"5"] forState:UIControlStateNormal];
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
    
    [self loadData];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:KNOTIFICATION_onMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recording:) name:KNOTIFICATION_onRecordingAmplitude object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
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
        
        
        [self.view addSubview:_emojiView];
        
    });
    
    [[DeviceDBHelper sharedInstance].msgDBAccess markMessagesAsReadOfSession:self.sessionId];
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
    
    [[DeviceDBHelper sharedInstance].msgDBAccess markMessagesAsReadOfSession:self.sessionId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
    
    
    
}

-(void)movieFinish{
    
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

-(MedieMessageType)getMessageMediaType:(NSString*)displayName{
    if ([displayName hasSuffix:@".amr"])
    {
        return MedieMessageType_Voice;
    }
    else if ([displayName hasSuffix:@".jpg"] || [displayName hasSuffix:@".png"])
    {
        return MedieMessageType_Image;
    }
#ifdef Support_Video_Send
    else if ([displayName hasSuffix:@".mp4"])
    {
        return MedieMessageType_Video;
    }
#endif
    else if ([displayName componentsSeparatedByString:@" "][0])
    {
        return MedieMessageType_Location;
    }
    else{
        return MedieMessageType_File;
    }
}
#pragma mark - notification method


-(void)refreshTableView:(NSNotification*)notification{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (notification == nil || notification.object == nil) {
        [self loadData];
        [self.messageArray removeAllObjects];
        [self.messageArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getLatestHundredMessageOfSessionId:self.sessionId]];
        
        [self.tableView reloadData];
    }
    else{
        ECMessage *message = (ECMessage*)notification.object;
        if (![message.sessionId isEqualToString:self.sessionId]) {
            return;
        }
        [self.messageArray addObject:message];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    if (self.messageArray.count>0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

/**
 *@brief 键盘的frame更改监听函数
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification
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
    CGFloat height;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            height = 100.0;
        }
        if(indexPath.row == 1)
        {
            height = 170;
        }
        if(indexPath.row == 2)
        {
            
            height = [ChatViewVoiceCell getHightOfCellViewWith:self.playVoiceMessage.messageBody];
            
            
        }
        
    }
    
#warning 显示的时间高度为30.0f
    return height;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.hostVoiceMessage)
    {
        return 3;
    }else
    {
        return 2;
    }
    
    
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * normalCell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!normalCell)
    {
        normalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            HostVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HostVideo"];
            if(cell == nil)
            {
                cell = [[HostVideoCell alloc] initWithIsSender:YES reuseIdentifier:@"HostVideo"];
            }
            cell.playBlock = ^(NSString * videoUrl)
            {
                play = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:videoUrl]];
                play.view.frame=CGRectMake(0, self.view.center.y - 184 , 320, 240);
                UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
                view.backgroundColor = [UIColor whiteColor];
                [play.view addSubview:view];
                [play.moviePlayer prepareToPlay];
                [play.moviePlayer play];
                [self.view addSubview:play.view];
                
            };
            
            [cell config:self.HostNewsDic[@"content"]];
            return cell;
        }
        if(indexPath.row == 1)
        {
            HostVoteCell * cell = [tableView dequeueReusableCellWithIdentifier:@"HostVote"];
            if(cell == nil)
            {
                cell = [[HostVoteCell alloc] initWithIsSender:YES reuseIdentifier:@"HostVote"];
            }
            [cell config:self.HostNewsDic[@"vote"]];
            return cell;
        }
        if(indexPath.row == 2)
        {
            ChatViewVoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceCell"];
            if(!cell)
            {
                cell = [[ChatViewVoiceCell alloc] initWithIsSender:YES reuseIdentifier:@"VoiceCell"];
            }
            [cell bubbleViewWithData:self.hostVoiceMessage];
            return cell;
        }
       
        
    }
    
    return normalCell;
    
}

-(BOOL)fileExists
{
    BOOL exist ;
    NSString * url = self.HostNewsDic[@"voice"][@"voiceUrl"];
    NSString * fileName = [[url componentsSeparatedByString:@"http://198.11.177.144:8880/u/cms/www/201504/"] lastObject];
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSFileManager * fileManager = [[NSFileManager alloc] init];
    if([fileManager fileExistsAtPath:path])
    {
        exist = YES;
        self.hostVoiceFile = path;
        self.hostVoiceFileDisplayName = fileName;
    }else
    {
        exist = NO;
    }
    return exist;
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


#pragma mark - UIResponder custom
- (void)dispatchCustomEventWithName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    ECMessage * message = [userInfo objectForKey:KResponderCustomECMessageKey];
    if ([name isEqualToString:KResponderCustomChatViewFileCellBubbleViewEvent]) {
        [self fileCellBubbleViewTap:message];
    }
    else if ([name isEqualToString:KResponderCustomChatViewImageCellBubbleViewEvent]) {
        [self imageCellBubbleViewTap:message];
    }
    else if ([name isEqualToString:KResponderCustomChatViewVoiceCellBubbleViewEvent]) {
        [self voiceCellBubbleViewTap:message];
    }
    else if ([name isEqualToString:KResponderCustomChatViewVideoCellBubbleViewEvent]) {
        [self videoCellPlayVideoTap:message];
    }
    else if ([name isEqualToString:KResponderCustomChatViewCellResendEvent]){
        nameNum = 0;
        ChatViewCell *resendCell = [userInfo objectForKey:KResponderCustomTableCellKey];
        ECMessage *message = resendCell.displayMessage;
        [self.messageArray removeObject:message];
        [[DeviceChatHelper sharedInstance] resendMessage:message];
        [self.messageArray addObject:message];
        [self.tableView reloadData];
    }
    
}

-(void)videoCellPlayVideoTap:(ECMessage*)message
{
    ECMediaMessageBody *mediaBody = (ECMediaMessageBody*)message.messageBody;
    MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]]];
    NSLog(@"%@",[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]);
    [self presentViewController:playerView animated:NO completion:nil];
}

-(void)fileCellBubbleViewTap:(ECMessage*)message{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"无法打开该文件";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)playVoiceMessage:(ECMessage*)message{
    NSNumber* isplay = objc_getAssociatedObject(message, &KVoiceIsPlayKey);
    if (isplay == nil) {
        //首次点击
        isplay = @YES;
    }
    else{
        isplay = @(!isplay.boolValue);
    }
    
    if (self.playVoiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        self.playVoiceMessage = nil;
    }
    
    __weak __typeof(self) weakSelf = self;
    if (isplay.boolValue)
    {
        self.playVoiceMessage = message;
        objc_setAssociatedObject(message, &KVoiceIsPlayKey, isplay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager playVoiceMessage:(ECMediaMessageBody*)message.messageBody completion:^(ECError *error) {
            if (weakSelf) {
                objc_setAssociatedObject(weakSelf.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                weakSelf.playVoiceMessage = nil;
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }
        }];
        
        [weakSelf.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messageArray indexOfObject:self.playVoiceMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
    }
}

-(void)voiceCellBubbleViewTap:(ECMessage*)message{
    
    ECMediaMessageBody* mediaBody = (ECMediaMessageBody*)message.messageBody;
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
        
        [self playVoiceMessage:message];
        
    } else if(message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0){
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"正在获取文件";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}

-(void)imageCellBubbleViewTap:(ECMessage*)message{
    
    if (message.messageBody.messageBodyType == MessageBodyType_Media) {
        ECMediaMessageBody *mediaBody = (ECMediaMessageBody*)message.messageBody;
        
        if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
            
            
            if([message.userData componentsSeparatedByString:@" "].count > 1)
            {
                NSArray * locationArray = [message.userData componentsSeparatedByString:@" "];
                double lat = [locationArray[0] doubleValue];
                double lon = [locationArray[1] doubleValue];
                CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                MessageMapViewController * vc = [[MessageMapViewController alloc] init];
                vc.senderLocation = userLocation;
                [self.navigationController pushViewController:vc animated:YES];
            }else
            {
                [self showPhotoBrowser:[NSArray arrayWithObject:mediaBody.localPath]];
            }
            
            
        } else if(message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0){
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在获取文件";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self)weakSelf = self;
            
            [[DeviceChatHelper sharedInstance] downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (error.errorCode == ECErrorType_NoError) {
                    
                    if ([mediaBody.localPath hasSuffix:@".jpg"] || [mediaBody.localPath hasSuffix:@".png"]) {
                        
                        [weakSelf showPhotoBrowser:[NSArray arrayWithObject:mediaBody.localPath]];
                    }
                }else{
                    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"获取文件失败";
                    hud.margin = 10.f;
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:2];
                }
            }];
        }
    }
}

#pragma mark - Photo browser
-(void)showPhotoBrowser:(NSArray*)imageArray{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [MWPhoto photoWithURL:object];
            }
            else if ([object isKindOfClass:[NSString class]])
            {
                photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:object]];
            }
            [photoArray addObject:photo];
        }
        
        self.photos = photoArray;
    }
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = NO;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    [photoBrowser setCurrentPhotoIndex:0];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return self.photos[index];
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
    [_emojiBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
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
    [_recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    _recordBtn.frame = CGRectMake(frame_x, 5.0f, _emojiBtn.frame.origin.x-frame_x-5.0f, 31.0f);
    [_containerView addSubview:_recordBtn];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_recordBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [_recordBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragInside];
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
        
    }
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
    
    ECNoTitleAlert(@"改状态下不能发送表情");
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
        if (self.messageArray.count>0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}


/**
 *@brief 根据按钮改变工具栏的显示布局
 */
-(void)switchToolbarDisplay:(id)sender{
    UIButton*button = (UIButton*)sender;
    
    //如果上次显示内容为录音，更改显示
    if (toolbarDisplay == ToolbarDisplay_Record) {
        CGRect frame = _containerView.frame;
        frame.size.height = _oldInputHeight;
        _containerView.frame = frame;
        
        _inputView.hidden = NO;
        _recordBtn.hidden = YES;
    }
    
    //如果上次显示内容为表情
    if (toolbarDisplay == ToolbarDisplay_Emoji) {
        CGRect frame = _emojiView.frame;
        frame.origin.y = self.view.frame.size.height;
        _emojiView.frame=frame;
    }
    
    
    //如果两次按钮的相同触发输入文本
    if (button.tag == toolbarDisplay) {
        
        toolbarDisplay = ToolbarDisplay_None;
        [_inputTextView becomeFirstResponder];
    } else {
        
        CGFloat framey = self.view.frame.size.height-ToolbarInputViewHeight;
        if (button.tag == ToolbarDisplay_More) {
            //显示出附件功能页面
            framey = viewHeight-_containerView.frame.size.height;
        }else if(button.tag == ToolbarDisplay_Emoji){
            //显示表情页面
            framey = viewHeight-_containerView.frame.size.height-126.0f;
            _inputTextView.selectedRange = NSMakeRange(_inputTextView.text.length,0);
            void(^animations)() = ^{
                CGRect frame = _emojiView.frame;
                frame.origin.y = viewHeight-_emojiView.frame.size.height;
                _emojiView.frame=frame;
            };
            [UIView animateWithDuration:0.25 delay:0.1f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
            
        }else if(button.tag == ToolbarDisplay_Record){
            //显示录音按钮，并返回默认的布局
            CGRect frame = _containerView.frame;
            _oldInputHeight = frame.size.height;
            frame.size.height = ToolbarDefaultTotalHeigth;
            _containerView.frame = frame;
            _inputView.hidden = YES;
            _recordBtn.hidden = NO;
            framey = viewHeight-ToolbarInputViewHeight;
        }
        
        toolbarDisplay = (ToolbarDisplay)button.tag;
        
        if (_isDisplayKeyborad) {
            //如果显示键盘，在keyboardWillChangeFrame中更改显示
            [self.view endEditing:YES];
        } else {
            //如果未显示键盘，更改显示
            [self toolbarDisplayChangedToFrameY:framey andDuration:0.25];
        }
    }
    
    //更换按钮上显示的图片
    if (toolbarDisplay == ToolbarDisplay_Record) {
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"37"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    } else if(toolbarDisplay == ToolbarDisplay_Emoji){
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"42"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
    }
    else{
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"42"] forState:UIControlStateNormal];
        [_switchVoiceBtn setImage:[UIImage imageNamed:@"voice_icon_on"] forState:UIControlStateHighlighted];
        [_emojiBtn setImage:[UIImage imageNamed:@"37"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - 录音操作

//按下操作
-(void)recordButtonTouchDown{
    
    if (self.playVoiceMessage) {
        //如果有播放停止播放语音
        objc_setAssociatedObject(self.playVoiceMessage, &KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        [self.tableView reloadData];
        self.playVoiceMessage = nil;
    }
    
    static int seedNum = 0;
    if(seedNum >= 1000)
        seedNum = 0;
    seedNum++;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *file = [NSString stringWithFormat:@"tmp%@%03d.amr", currentDateStr, seedNum];
    
    ECMediaMessageBody * messageBody = [[ECMediaMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file] displayName:file];
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager startVoiceRecording:messageBody error:^(ECError *error, ECMediaMessageBody *messageBody) {
        [weakSelf.view sendSubviewToBack:weakSelf.amplitudeImageView];
        if (error.errorCode == ECErrorType_RecordTimeOut) {
            
            ECMessage * message = [[ECMessage alloc] initWithReceiver:nil body:messageBody];
            self.hostVoiceMessage = message;
            NSData * voiceData = [NSData dataWithContentsOfFile:messageBody.localPath];
            [AccountRequest hostSendVoice:voiceData withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0 && stateDic[@"data"])
                {
                    [self.tableView reloadData];
                }
            } fail:^( NSError *err) {
                ECNoTitleAlert(@"网络超时");
            }];
        }
        
    }];
    _recordInfoLabel.text = @"手指上划,取消发送";
    [self.view bringSubviewToFront:_amplitudeImageView];
}

//按钮外抬起操作
-(void)recordButtonTouchUpOutside{
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECMediaMessageBody *messageBody) {
        [weakSelf.view sendSubviewToBack:weakSelf.amplitudeImageView];
    }];
}

//按钮内抬起操作
-(void)recordButtonTouchUpInside{
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECMediaMessageBody *messageBody) {
        [weakSelf.view sendSubviewToBack:weakSelf.amplitudeImageView];
        if (error.errorCode == ECErrorType_NoError) {
           
            NSData * voiceData = [NSData dataWithContentsOfFile:messageBody.localPath];
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hostVoiceMessage = [[ECMessage alloc] initWithReceiver:nil body:messageBody];
            hud.labelText = @"主持人公共语音发送中";
            hud.removeFromSuperViewOnHide = YES;
            
            [AccountRequest hostSendVoice:voiceData withSucc:^(NSDictionary * stateDic) {
                if([stateDic[@"status"] intValue] == 0 && stateDic[@"data"])
                {
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.tableView reloadData];
                }else
                {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    ECNoTitleAlert(stateDic[@"message"]);
                }
            } fail:^(NSError *err) {
                ECNoTitleAlert(@"网络超时");
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            
        }
        else if  (error.errorCode == ECErrorType_RecordTimeTooShort)
        {
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.userInteractionEnabled = NO;
            hud.labelText = @"录音时间过短";
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
            
        }
    }];
}

//手指划出按钮
-(void)recordDragOutside{
    _recordInfoLabel.text = @"松开手指,取消发送";
}

//手指划入按钮
-(void)recordDragInside{
    _recordInfoLabel.text = @"手指上划,取消发送";
}

-(void)recording:(NSNotification*)notification
{
    double amplitude = ((NSNumber*)notification.object).doubleValue;
    if (amplitude<0.14) {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_07"];
    }
    else if(0.14<= amplitude <0.28)
    {
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_06"];
    }
    else if(0.28<= amplitude <0.42){
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_05"];
    }
    else if(0.42<= amplitude <0.57){
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_04"];
    }
    else if(0.57<= amplitude <0.71){
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_03"];
    }
    else if(0.71<= amplitude <0.85){
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_02"];
    }
    else if(0.85<= amplitude){
        _amplitudeImageView.image = [UIImage imageNamed:@"press_speak_icon_01"];
    }
}

#pragma mark - moreview 动作


/**
 *@brief 图片按钮
 */
-(void)pictureBtnTap:(id)sender{
    
    [self endOperation];
    ECNoTitleAlert(@"该状态下不支持发图片");
    return;
    // 弹出照片选择
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

/**
 *@brief 照相按钮
 */
-(void)cameraBtnTap:(id)sender{
    
    [self endOperation];
    ECNoTitleAlert(@"该状态下不支持拍照");
    return;
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self presentViewController:imagePicker animated:YES completion:NULL];
}




#pragma mark - 保存音视频文件
- (NSURL *)convertToMp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                               presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* fileName = [NSString stringWithFormat:@"%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSString* path = [NSString stringWithFormat:@"file:///private%@",[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
        mp4Url = [NSURL URLWithString:path];
        
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (UIImage *)fixOrientation:(UIImage *)aImage
{   // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform     // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {          case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:              CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);              break;
    }       // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(NSString*)saveToDocment:(UIImage*)image
{
    UIImage* fixImage = [self fixOrientation:image];
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
    NSString* fileName =[NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    //图片按0.5的质量压缩－》转换为NSData
    NSData *imageData = UIImageJPEGRepresentation(fixImage, 0.5);
    [imageData writeToFile:filePath atomically:YES];
    CGSize size = CGSizeMake((130/fixImage.size.height) * fixImage.size.width, 130);
    UIImage * newImage = [CommonTools compressImage:fixImage withSize:size];
    NSData * photo = UIImageJPEGRepresentation(newImage, 0.8);
    NSString * compressfilePath = [NSString stringWithFormat:@"%@.jpg_press", filePath];
    [photo writeToFile:compressfilePath atomically:YES];
    
    return filePath;
    
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
        if (self.messageArray.count>0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    [UIView animateWithDuration:0.1 delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        ECNoTitleAlert(@"该状态下不支持文字发送");
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

@end
