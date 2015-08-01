//
//  HomeViewController.m
//  PageXib
//
//  Created by mac on 15/2/5.
//  Copyright (c) 2015年 wsd. All rights reserved.
//

#import "JW_HomeViewController.h"
#import "DeviceDelegateHelper.h"
#import "AccountRequest.h"
#import "DemoGlobalClass.h"
#import "ChatViewController.h"
#import "ActivityViewController.h"
#import "UIImageView+WebCache.h"
#import "ECSession.h"
#import "JWLoginViewController.h"
#import "HostChatVoiceViewController.h"
#import "NoticeViewController.h"
#import "TopicViewController.h"


@interface JW_HomeViewController () <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

{
    UITableView * _tableView;
    UIView * FM_BGView;
    UIView * FM_PlayerView;
    UIButton * FM_playBtn;
    UIButton * naviBtn;
    BOOL isShow;
    BOOL isPlay;
    UIView * _linkview;
    int unreadTag;
    UITableViewCell * _memoryCell;
    
}
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong,nonatomic)NSMutableArray * sessionArray;
@end

@implementation JW_HomeViewController

-(void)viewWillDisAppear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.title = @"@RCI";
    //如果网络状态改变，自动重新登陆
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLoginClient) name:KNOTIFICATION_onNetworkChanged object:nil];
    
    [self createNav];
    self.sessionArray = [NSMutableArray arrayWithCapacity:0];
    
    //消息变化时 发动通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkSuccess:) name:KNOTIFICATION_onConnected object:nil];
    
    [self createTableView];

    
    [self prepareDisplay];
    
}

-(void)createNav
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(intoChatView) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[UIImage imageNamed:@"hostVoice"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0, 25, 20);
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIButton * logout = [UIButton buttonWithType:UIButtonTypeCustom];
    [logout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
    [logout setBackgroundImage:[UIImage imageNamed:@"tuichu"] forState:UIControlStateNormal];
    logout.frame = CGRectMake(0, 0, 25, 20);
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logout];
}

-(void)Logout
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Pointe" message:@"Vraiment doit annuler?" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Oui", nil];
    av.tag = 1001;
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        
        //        注销
        if(buttonIndex == 1)
        {
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.removeFromSuperViewOnHide = YES;
            hub.labelText = @"Déconnecté...";
            [[ECDevice sharedInstance] logout:^(ECError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_Connacts];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:UserDefault_LoginUser];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_KickedOff]];
                
            }];
        }
    }
    
    
}


-(void)intoChatView
{
    HostChatVoiceViewController * vc = [[HostChatVoiceViewController alloc] initWithSessionId:nil];
    [self.tabBarController.navigationController pushViewController:vc animated:YES];
}

-(void)prepareDisplay
{
    
    self.sessionArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * allSessionArray = [NSMutableArray arrayWithCapacity:0];
    AppDelegate * delegate = [UIApplication sharedApplication].delegate;
    delegate.unReadNum = 0;
    //删除所有表格
//    [[DeviceDBHelper sharedInstance].msgDBAccess clearMessageTable];
    [allSessionArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getMyCustomSession]];
    for(int i = 0;i < allSessionArray.count;i++)
    {
        ECSession * session = allSessionArray[i];
        if (session.unreadCount > 0) {
            [self.sessionArray addObject:session];
            delegate.unReadNum += session.unreadCount;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = delegate.unReadNum;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnReadChange" object:[NSString stringWithFormat:@"%d",delegate.unReadNum]];
    [_tableView reloadData];
}


//获取主持人列表
-(void)loadData
{
    [AccountRequest getHostListRequestWithSucc:^(NSArray *data) {
        self.dataArray = [NSMutableArray arrayWithArray:data];
        [self prepareDisplay];
        
    }];
}


-(void)createTableView
{

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.sessionArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
            UILabel *noMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 100.0f, SCREEN_WIDTH, 50.0f)];
            noMsgLabel.text = @"暂无听众留言";
            noMsgLabel.textColor = [UIColor darkGrayColor];
            noMsgLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:noMsgLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
        UILongPressGestureRecognizer  * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        [cell.contentView addGestureRecognizer:longPress];
    }
    //主持人
    if(self.sessionArray.count > 0)
    {
        ECSession * session = [self.sessionArray objectAtIndex:indexPath.row];
        
        cell.detailTextLabel.text = session.text;
        cell.textLabel.text = @"暂无";
        cell.imageView.image = [self imageWithImage:[UIImage imageNamed:@"xiaolu"] scaledToSize:CGSizeMake(65, 65)];
        [AccountRequest getUserInfo:^(NSDictionary *UserInfo) {
            if([UserInfo[@"realname"] length] > 0)
            {
                cell.textLabel.text = UserInfo[@"realname"];
            }
            
            if([UserInfo[@"userImg"] length] > 0)
            {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:UserInfo[@"userImg"]]];
                cell.imageView.image = [self imageWithImage:cell.imageView.image scaledToSize:CGSizeMake(65, 65)];
            }
            
        } WithUserVoip:session.sessionId];
        
        if(session.unreadCount > 0)
        {
            for(UIView * view in cell.contentView.subviews)
            {
                if(view.tag == 100 + indexPath.row)
                {
                    [view removeFromSuperview];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnReadChange" object:[NSString stringWithFormat:@"%d",session.unreadCount]];
            UILabel * unreadNumLabel = [self createNumLabel:session.unreadCount];
            unreadNumLabel.tag = 100 + indexPath.row;
            [cell.contentView addSubview:unreadNumLabel];
            
        }
    }

    return cell;
}
//长按响应函数
-(void)cellLongPress:(UILongPressGestureRecognizer * )longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:_tableView];
        NSIndexPath * indexPath = [_tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确认要删除这个听众吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
        [sheet showInView:cell];
        _memoryCell = cell;
    }
}

//action代理函数
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"删除该会话";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        NSIndexPath * path = [_tableView indexPathForCell:_memoryCell];
        ECSession* session = [self.sessionArray objectAtIndex:path.row];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:session.sessionId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.sessionArray removeObjectAtIndex:path.row];
                _memoryCell = nil;
                [_tableView reloadData];
            });
        });
    }
}


//创建cell未读消息小红点
-(UILabel *)createNumLabel:(int)unreadNumber
{
    UILabel * unreadNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 20, 20)];
    unreadNumLabel.backgroundColor = [UIColor redColor];
    unreadNumLabel.textColor = [UIColor whiteColor];
    unreadNumLabel.layer.cornerRadius = 10;
    unreadNumLabel.textAlignment = NSTextAlignmentCenter;
    unreadNumLabel.font = [UIFont systemFontOfSize:12];
    unreadNumLabel.clipsToBounds = YES;
    unreadNumLabel.text = [NSString stringWithFormat:@"%d",unreadNumber];
    return unreadNumLabel;
    
}

//头像图片裁剪
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.sessionArray.count == 0)
    {
        return 1;
    }else
    {
        return self.sessionArray.count;
    }
}



//cell点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if(self.sessionArray.count == 0)
    {
        return;
    }
    
        ECSession * session = self.sessionArray[indexPath.row];
        NSString * sessionID = session.sessionId;

        ChatViewController * vc = [[ChatViewController alloc] initWithSessionId:sessionID];
        vc.hidesBottomBarWhenPushed = YES;
        //        vc.title = self.dataArray[indexPath.row][@"hostName"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnReadChange" object:@"0"];
    

        vc.cell = cell;
        vc.viewTag = 100 + indexPath.row;

        for(UIView * view in cell.contentView.subviews)
        {
            if(view.tag == 100 + indexPath.row)
            {
                [view removeFromSuperview];
            }
        }
    
        [self.navigationController pushViewController:vc animated:YES];
    
    
    
}


-(void)updateLoginStates:(LinkJudge)link
{
    if (link == success) {
        _tableView.tableHeaderView = nil;
        [_linkview removeFromSuperview];
    }
    else
    {
        [_linkview removeFromSuperview];
        _linkview = nil;
        
        _linkview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
        _linkview.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        if (link==failed) {
            UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8, 30, 30)];
            image.image = [UIImage imageNamed:@"messageSendFailed"];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 320-50 , 45)];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            label.text = @"无法连接到服务器";
            [_linkview addSubview:image];
            [_linkview addSubview:label];
        }
        if(link == linking)
        {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 310 , 45)];
            label.font = [UIFont systemFontOfSize:14];
            label.text = @"连接中...";
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            [_linkview addSubview:label];
        }
        _tableView.tableHeaderView = _linkview;
    }
}

-(void)linkSuccess:(NSNotification *)link
{
    ECError* error = link.object;
    if (error.errorCode == ECErrorType_NoError) {
        [self updateLoginStates:success];
    }
    else
    {
        [self updateLoginStates:failed];
    }
}

-(void)autoLoginClient{
   
    NSString * userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    
    NSString * passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"PassWord"];
    

    
    [AccountRequest LoginRequestWithUserName:userName PassWord:passWord  succ:^(NSDictionary * responseData) {

        
        if([responseData[@"status"] integerValue] == 1)
        {
            ECNoTitleAlert(responseData[@"message"]);
            AppDelegate * delegate = [UIApplication sharedApplication].delegate;
            delegate.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[JWLoginViewController alloc] init]];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            return;
        }
        
        NSDictionary * data = responseData[@"data"];
        
        [[DeviceDBHelper sharedInstance] openDataBasePath:data[@"voipAccount"]];
        ECLoginInfo * loginInfo = [[ECLoginInfo alloc] initWithAccount:data[@"voipAccount"] Password:data[@"voipPassword"]];
        loginInfo.subAccount = data[@"subAccountId"];
        loginInfo.subToken = data[@"subToken"];
        [DemoGlobalClass sharedInstance].loginInfo = loginInfo;
        [DemoGlobalClass sharedInstance].userInfoDic = [data mutableCopy];
        
        if ([DemoGlobalClass sharedInstance].isLogin == NO) {
            
            [self updateLoginStates:linking];
            
            //        ECLoginInfo *loginInfo = [DemoGlobalClass sharedInstance].loginInfo;
            
            [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error) {
                

                if (error.errorCode==ECErrorType_NoError) {
                    [self updateLoginStates:success];
                    [self prepareDisplay];
                    
                }
                else
                {
                    [self updateLoginStates:failed];
                }
                
            }];
        }
        
    }];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return M_PI_4 / 1000000000000;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return M_PI_4 / 1000000000000;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
