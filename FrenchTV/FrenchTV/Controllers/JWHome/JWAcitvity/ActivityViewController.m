//
//  ActivityViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/2/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "ActivityViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ActivityViewController () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>

{
    MJRefreshHeaderView *header;
    MJRefreshFooterView *footer;
    
    int page;
    
    BOOL playerIsPlay;
    
    UIScrollView * BGScrollView;
    
    UITextField * commentField;
    
    MPMoviePlayerViewController * play;
    
//    ActivityWillBegin
    
    UILabel * willTitleLab;
    UILabel * willTimeLab;
    UILabel * willSmallTitleLab;
    UILabel * willDetailLab;
    
//    ActivityIsBegining
    
    UILabel * beginTitleLab;
    UILabel * beginDetailLab;
    UITableView * _tableView;
    
    
//    ActivityIsOver
    
    
}
//活动状态
@property (nonatomic) ActivityState state; //默认为 0

@property (nonatomic, strong) UILabel * titleLab;
@property (nonatomic, strong) UILabel * timeLab;
@property (nonatomic, strong) UIButton * personBtn;
@property (nonatomic, strong) UIImageView * videoImg;
@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UIView * commonBGView;

@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation ActivityViewController

- (void)dealloc
{
    [header free];
    [footer free];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftNav];
    NSLog(@"%d",_state);
    NSLog(@"contentTitle = %@",self.dataModel.contentTitle);
    NSLog(@"imgList = %@",self.dataModel.imgList);

    page = 1;
    playerIsPlay = NO;
    [self createCommonUI];
    [self createUnCommonUI];
    self.titleLab.text =  self.dataModel.contentTitle;
    self.timeLab.text = self.dataModel.contentReleaseDate;

//    [self addComment];
    
}

-(void)createLeftNav
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"17"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


//测试
-(void)addComment
{
    [AccountRequest addComment:^(NSDictionary *dic) {
        
        NSLog(@"啊实打实大师的");
//        [_tableView reloadData];
        
    } withContentId:self.dataModel.contentId withText:@"阿什顿卡接收到卡萨丁"];
}

-(void)createRefresh
{
    header = [MJRefreshHeaderView header];
    footer = [MJRefreshFooterView footer];
    
    __weak ActivityViewController * avc = self;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refresh)
    {
        [avc loadData:refresh];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView * refresh)
    {
        [avc loadData:refresh];
    };
    
    header.scrollView = _tableView;
    footer.scrollView = _tableView;
    
    [header beginRefreshing];
}

-(void)loadData:(MJRefreshBaseView *)refresh
{
    if (refresh == header)
    {
        //上拉刷新
        page = 1;
    }
    else
    {
        //下拉加载
        page ++;
        
    }
    
    [self getDataWithPage];


}

-(void)getDataWithPage
{
    [AccountRequest getActivityComment:^(NSDictionary *dic) {
        
        [header endRefreshing];

        //成功获取评论
        NSLog(@"dic = %@",dic);
        
        if (page == 1) {
            self.dataArray = nil;
            self.dataArray = [NSMutableArray arrayWithCapacity:0];
        }
        
        [self.dataArray addObjectsFromArray:dic[@"comments"]];
        [_tableView reloadData];
        
        
    } withContentId:self.dataModel.contentId withPage:page];
}

-(void)createCommonUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    BGScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [UIScreen mainScreen].bounds.size.height - 64)];
    BGScrollView.delegate = self;
//    BGScrollView.bounces = NO;
    [self.view addSubview:BGScrollView];
    
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 50)];
    _titleLab.numberOfLines = 0;
    _titleLab.text = @"Je les en perspectives,qui sont, a mon avis";
    _titleLab.font = [UIFont systemFontOfSize:20];
    [BGScrollView addSubview:_titleLab];
    
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
    _timeLab.textColor = [UIColor lightGrayColor];
    _timeLab.text = @"2015/1/7";
    [BGScrollView addSubview:_timeLab];
    
    self.personBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _personBtn.frame = CGRectMake(220, 70, 100, 30);
    _personBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_personBtn setTitleColor:MakeRgbColor(141, 193, 225, 1) forState:UIControlStateNormal];
    [_personBtn setTitle:@"Vogue Ma" forState:UIControlStateNormal];
    [BGScrollView addSubview:_personBtn];
    
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(20, 115, SCREEN_WIDTH - 40, 1)];
    line.backgroundColor = MakeRgbColor(235, 235, 235, 1);
    [BGScrollView addSubview:line];
    
    _videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 130, SCREEN_WIDTH - 20, SCREEN_WIDTH /2 + 40)];
    _videoImg.contentMode = UIViewContentModeScaleAspectFit;
    _videoImg.backgroundColor = [UIColor blackColor];
    [BGScrollView addSubview:_videoImg];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _playBtn.frame = CGRectMake(SCREEN_WIDTH /2 - 20, SCREEN_WIDTH /2 + 50, 40, 40);
    [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [BGScrollView addSubview:_playBtn];
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"33"] forState:UIControlStateNormal];
    
    _commonBGView = [[UIView alloc]initWithFrame:CGRectMake(20, 180 + SCREEN_WIDTH / 2, SCREEN_WIDTH - 40, 200)];
//    _commonBGView.backgroundColor = [UIColor lightGrayColor];
    [BGScrollView addSubview:_commonBGView];
    
}


-(void)createUnCommonUI
{
    switch (_state) {
        case ActivityWillBegin:
        {
            _playBtn.hidden = YES;
            BGScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, [UIScreen mainScreen].bounds.size.height - self.tabBarController.navigationController.navigationBar.bounds.size.height);
            willTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _commonBGView.bounds.size.width, 30)];
            willTitleLab.text = @"activites duree";
            willTitleLab.font = [UIFont systemFontOfSize:20];
            [_commonBGView addSubview:willTitleLab];
            
            willTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, _commonBGView.bounds.size.width, 25)];
            willTimeLab.textColor = [UIColor darkGrayColor];
            willTimeLab.text = @"2015/1/7 12:00 - 2015/1/8 12:00";
            [_commonBGView addSubview:willTimeLab];
            
            willSmallTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, _commonBGView.bounds.size.width, 30)];
            willSmallTitleLab.text = @"activites";
            willSmallTitleLab.font = [UIFont systemFontOfSize:20];
            [_commonBGView addSubview:willSmallTitleLab];
            
            willDetailLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, _commonBGView.bounds.size.width, 35)];
            willDetailLab.textColor = [UIColor darkGrayColor];
            willDetailLab.font = [UIFont systemFontOfSize:14];
            willDetailLab.text = @"Jes les en perspective,qui sont,mon avi.Je les en perspective,qui sont,a mon avis";
            willDetailLab.numberOfLines = 0;
            [_commonBGView addSubview:willDetailLab];
            
        }
            break;
            
        case ActivityIsBegining:
        {
            
            _playBtn.hidden = NO;
            _videoImg.hidden = YES;

            beginTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _commonBGView.bounds.size.width, 20)];
            beginTitleLab.text = @"Critiquer debuter";
            beginTitleLab.font = [UIFont systemFontOfSize:20];
            [_commonBGView addSubview:beginTitleLab];
            
            beginDetailLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, _commonBGView.bounds.size.width, 35)];
            beginDetailLab.textColor = [UIColor darkGrayColor];
            beginDetailLab.font = [UIFont systemFontOfSize:14];
            beginDetailLab.text = @"Jes les en perspective,qui sont,mon avis.";
            beginDetailLab.numberOfLines = 0;
            [_commonBGView addSubview:beginDetailLab];
            
            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, _commonBGView.bounds.size.width, 200) style:UITableViewStyleGrouped];
            _tableView.bounces = NO;
            _tableView.layer.borderWidth = 1;
            _tableView.layer.masksToBounds = YES;
            _tableView.layer.borderColor = MakeRgbColor(230, 230, 230, 1).CGColor;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_commonBGView addSubview:_tableView];
            
            BGScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 610);
            
            commentField = [[UITextField alloc]initWithFrame:CGRectMake(5, SCREEN_HEIGHT - 64 - 40, SCREEN_WIDTH - 10, 40)];
            commentField.layer.cornerRadius = 15;
            commentField.layer.borderWidth = 0.5;
            commentField.layer.borderColor = [UIColor lightGrayColor].CGColor;
            commentField.layer.masksToBounds = YES;
            commentField.backgroundColor = MakeRgbColor(248, 248, 248, 1);
            commentField.returnKeyType = UIReturnKeySend;
            commentField.placeholder = @"   输入评论内容...";
            commentField.delegate = self;
            [self.view addSubview:commentField];
            [self registerForKeyboardNotifications];

            [self createRefresh];

        }
            break;
            
        case ActivityIsOver:
        {
            _playBtn.hidden = NO;
            _videoImg.hidden = NO;

            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _commonBGView.bounds.size.width, 260) style:UITableViewStyleGrouped];
            _tableView.bounces = NO;
            _tableView.layer.borderWidth = 1;
            _tableView.layer.masksToBounds = YES;
            _tableView.layer.borderColor = MakeRgbColor(230, 230, 230, 1).CGColor;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_commonBGView addSubview:_tableView];
            
            BGScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 610);
            
            commentField = [[UITextField alloc]initWithFrame:CGRectMake(5, SCREEN_HEIGHT - 64 - 40, SCREEN_WIDTH - 10, 40)];
            commentField.layer.cornerRadius = 15;
            commentField.layer.borderWidth = 0.5;
            commentField.layer.borderColor = [UIColor lightGrayColor].CGColor;
            commentField.layer.masksToBounds = YES;
            commentField.backgroundColor = MakeRgbColor(248, 248, 248, 1);
            commentField.placeholder = @"   输入评论内容...";
            commentField.returnKeyType = UIReturnKeySend;
            commentField.delegate = self;
            [self.view addSubview:commentField];
            [self registerForKeyboardNotifications];
            
            [self createRefresh];

            
        }
            break;
            
        default:
        {
            _playBtn.hidden = YES;
            [play.view removeFromSuperview];
            NSLog(@"%@",_dataModel.imgList);
            [_videoImg removeFromSuperview];

            if (_dataModel.imgList != 0)
            {

                for (int i = 0; i < _dataModel.imgList.count; i ++) {
                    UIImageView * imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 130 + i * (SCREEN_WIDTH /2 + 50), SCREEN_WIDTH - 20, SCREEN_WIDTH /2 + 40)];
                    [imgV sd_setImageWithURL:[NSURL URLWithString:_dataModel.imgList[i][@"imgUrl"]]];
                    
                    [BGScrollView addSubview:imgV];
                    
                    if (i == _dataModel.imgList.count - 1) {
                        BGScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, imgV.bounds.size.height + imgV.frame.origin.y);
                    }
                    
                }
            }
            else
            {
                [_videoImg sd_setImageWithURL:[NSURL URLWithString:self.dataModel.imgTxt]];
            }

            

        }
            break;
    }
}


-(void)playBtnClick:(UIButton *)sender
{
    if (playerIsPlay) {
        playerIsPlay = NO;
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"33"] forState:UIControlStateNormal];
    }
    else
    {
        playerIsPlay = YES;
        //播放
        _playBtn.hidden = YES;
        _videoImg.hidden = YES;

        play=[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:self.dataModel.contentMediaPath]];
        
        //http://112.231.23.20/live/fhzw/playlist.m3u8
        //设置播放器大小
        play.view.frame=CGRectMake(10, 130, SCREEN_WIDTH - 20, SCREEN_WIDTH /2+ 40);
        //设置缓冲播放
        [play.moviePlayer prepareToPlay];
        
        [BGScrollView addSubview:play.view];

        [play.moviePlayer play];
//        [_playBtn setBackgroundImage:[UIImage imageNamed:@"34"] forState:UIControlStateNormal];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ID"];
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(100, 99.5, cell.bounds.size.width - 110, 0.5)];
        view.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:view];
        
        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(180, 33, SCREEN_WIDTH - 200, 20)];
        lab.tag = 100;
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:lab];

    }
    
    if (self.dataArray.count != 0 && self.dataArray)
    {
        
//        NSLog(@"%@",self.dataArray[indexPath.row]);
        if (![[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"] isEqualToString:@""]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"]]];
        }
        else
        {
                cell.imageView.image = [UIImage imageNamed:@"xiaolu.jpg"];
        }
        cell.textLabel.text = self.dataArray[indexPath.row][@"commentUserName"];
//        cell.textLabel.text = @"Gestion";
        cell.detailTextLabel.text = self.dataArray[indexPath.row][@"commentText"];
        UILabel * timeLab = (UILabel *)[cell viewWithTag:100];
        timeLab.text =[self.dataArray[indexPath.row][@"commentTime"] substringToIndex:10];
    }
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0000001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _commonBGView.bounds.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(3, 8, 2, 24)];
    line.backgroundColor = MakeRgbColor(124, 199, 202, 1);
    [view addSubview:line];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 24)];
    lab.textColor = [UIColor lightGrayColor];
    lab.font = [UIFont systemFontOfSize:20];
    lab.text = @"Critiquer";
    
    [line addSubview:lab];
    
    return view;
    
}
- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}

#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [commentField resignFirstResponder];
}



//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"hight_hitht:%f",kbSize.height);

    [UIView animateWithDuration:0.1 animations:^{
        
        CGRect fra = commentField.frame;
        fra.origin.y = SCREEN_HEIGHT - (kbSize.height + 64 + 40);
        commentField.frame = fra;
        
    }];
    
    //输入框位置动画加载
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //do something
    [UIView animateWithDuration:0.1 animations:^{
        
        CGRect fra = CGRectMake(5, SCREEN_HEIGHT - 70 - 40, SCREEN_WIDTH - 10, 40);
        commentField.frame = fra;

    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [AccountRequest addComment:^(NSDictionary *dic) {
        
        NSLog(@"评论成功");
        [header beginRefreshing];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD creatembHub:@"评论成功"];
        textField.text = @"";
        
    } withContentId:self.dataModel.contentId withText:textField.text];
    
    return YES;
}


-(id)init
{
    if (self = [super init]) {
        self.state = ActivityWillBegin;
        self.dataModel = [[NoticeCellModel alloc]init];
        
    }
    
    return self;
}

-(id)initWithActivityState:(ActivityState)aState
{
    if (self = [super init]) {
        self.state = aState;
        self.dataModel = [[NoticeCellModel alloc]init];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//时间显示内容
-(NSString *)getDateDisplayString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    else
    {
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"今天 HH:mm:ss";
        }
        else if((nowCmps.day-myCmps.day)==1)
        {
            dateFmt.dateFormat = @"昨天 HH:mm:ss";
        }
        else{
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
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
