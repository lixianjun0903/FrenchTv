//
//  HostMessageViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/13.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "HostMessageViewController.h"
#import "DeviceDelegateHelper.h"
#import "AccountRequest.h"
#import "DemoGlobalClass.h"
#import "ChatViewController.h"
#import "ActivityViewController.h"
#import "UIImageView+WebCache.h"
#import "ECSession.h"
#import "NoticeViewController.h"
#import "TopicViewController.h"

@interface HostMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * _tableView;
    
    int unreadTag;
    
    
}
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong,nonatomic)NSMutableArray * sessionArray;
@end

@implementation HostMessageViewController

-(void)viewWillDisAppear:(BOOL)animated
{
    [AppDelegate getTabbar].tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //如果网络状态改变，自动重新登陆
    [self createLeftNav];
    
    
    self.sessionArray = [NSMutableArray arrayWithCapacity:0];
    
    //消息变化时 发动通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];
    
    
    
    [self createTableView];
    [self loadData];
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


-(void)prepareDisplay
{
    
    [self.sessionArray removeAllObjects];
    [self.sessionArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getMyCustomSession]];
    AppDelegate * delegate = [UIApplication sharedApplication].delegate;
    delegate.unReadNum = 0;
    for(int i = 0 ; i < self.sessionArray.count;i++)
    {
        ECSession * session = self.sessionArray[i];
        delegate.unReadNum += session.unreadCount;
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = delegate.unReadNum;
    
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
    //    NSLog(@"tableView = %f",(SCREEN_HEIGHT - TABBAR_HEIGHT- NAVI_HEIGHT));
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.layer.cornerRadius = 2;
        cell.imageView.layer.masksToBounds = YES;
        
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.numberOfLines = 1;
    }
    
    if(self.sessionArray.count > 0)
    {
        ECSession * session = self.sessionArray[indexPath.row];
        for(int i = 0;i<self.dataArray.count;i++)
        {
            if([session.sessionId isEqualToString:self.dataArray[i][@"hostVipAccount"]])
            {
                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.dataArray[i][@"hostImg"]]];
                UIImage * image = [self imageWithImage:cell.imageView.image scaledToSize:CGSizeMake(65, 65)];
                cell.imageView.image = image;
                cell.textLabel.text = self.dataArray[i][@"hostName"];
                cell.detailTextLabel.text = session.text;
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
                    unreadTag = unreadNumLabel.tag;
                    [cell.contentView addSubview:unreadNumLabel];
                    return cell;
                }
            }
        }
    }
    
    return cell;
}

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
    return self.sessionArray.count;
}

//cell点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        NSString * sessionID = self.dataArray[indexPath.row][@"hostVipAccount"];
    
        ChatViewController * vc = [[ChatViewController alloc] initWithSessionId:sessionID];
        vc.hidesBottomBarWhenPushed = YES;
        //        vc.title = self.dataArray[indexPath.row][@"hostName"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UnReadChange" object:@"0"];
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        for(UIView * view in cell.contentView.subviews)
        {
            if(view.tag == 100 + indexPath.row)
            {
                [view removeFromSuperview];
            }
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    
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
