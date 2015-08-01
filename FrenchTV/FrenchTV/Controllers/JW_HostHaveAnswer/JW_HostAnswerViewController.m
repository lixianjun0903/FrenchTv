//
//  JW_HostAnswerViewController.m
//  FrenchTV
//
//  Created by mac on 15/4/3.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "JW_HostAnswerViewController.h"
#import "DeviceDelegateHelper.h"
#import "AccountRequest.h"
#import "DemoGlobalClass.h"
#import "ChatViewController.h"
#import "ActivityViewController.h"
#import "UIImageView+WebCache.h"
#import "ECSession.h"
#import "JWLoginViewController.h"
#import "HostChatVoiceViewController.h"



@interface JW_HostAnswerViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    UITableView * _tableView;
    int unreadTag;
    UITableViewCell * _memoryCell;
    
}
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong,nonatomic)NSMutableArray * sessionArray;
@end

@implementation JW_HostAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];
    [self createTableView];
    [self prepareDisplay];
    
    
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
        if (!session.unreadCount > 0) {
            [self.sessionArray addObject:session];
            delegate.unReadNum += session.unreadCount;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = delegate.unReadNum;
    
    [_tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.sessionArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
            UILabel *noMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 100.0f, cell.frame.size.width, 50.0f)];
            noMsgLabel.text = @"暂无已读听众";
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //主持人
    if(self.sessionArray.count > 0)
    {
        ECSession * session = [self.sessionArray objectAtIndex:indexPath.row];
        cell.textLabel.text = @"暂无";
        cell.detailTextLabel.text = session.text;
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
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.sessionArray.count == 0)
    {
        return;
    }
    ECSession * session = self.sessionArray[indexPath.row];
    ChatViewController * vc = [[ChatViewController alloc] initWithSessionId:session.sessionId];
    [self.navigationController pushViewController:vc animated:YES];
}



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
