//
//  NoticeViewController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/5.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "NoticeViewController.h"
#import "NoticeActivityCell.h"
#import "NoticeCellModel.h"
#import "ActivityViewController.h"

@interface NoticeViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

{
    UITableView * _tableView;
    MJRefreshHeaderView * header;
    MJRefreshFooterView * footer;
    
    int page;
    
    
    
    //引用
    UITableViewCell * tempCell;
    NSIndexPath * tempPath;
    NSMutableArray * tempCellArray;
    NSMutableArray * tempLabArray;
    
    UITextField * commentField;

}

@property (strong, nonatomic) NSMutableArray * dataArray;

@property (strong, nonatomic) NSMutableArray * heightArray;

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftNav];
    // Do any additional setup after loading the view.
    
    [self createTableView];
    [self createRefreshView];
    [self registerForKeyboardNotifications];
    
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

- (void)dealloc
{
    [header free];
    [footer free];
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
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    NSLog(@"hight_hitht:%f",kbSize.height);
    
    
    commentField.frame = CGRectMake(10, SCREEN_HEIGHT - (kbSize.height + 45 + 64), SCREEN_WIDTH - 20, 40);
    
    
    //输入框位置动画加载
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //do something
    [commentField removeFromSuperview];
    commentField = nil;
    
}


-(void)btnBlock
{
    if (commentField == nil) {
        commentField = [[UITextField alloc]init];
        commentField.placeholder = @" Commentaires...";
        [self.view addSubview:commentField];
        commentField.returnKeyType = UIReturnKeySend;
        commentField.delegate = self;
        commentField.layer.cornerRadius = 10;
        commentField.layer.borderColor = [UIColor darkGrayColor].CGColor;
        commentField.layer.borderWidth = 0.5;
        commentField.layer.masksToBounds = YES;
        commentField.backgroundColor = MakeRgbColor(250, 250, 250, 1);
//        commentField.alpha = 0.8;

    }
    
    [commentField becomeFirstResponder];
    
    
}

-(void)addComment
{
    NSString * str = self.heightArray[tempPath.row];
    str = [NSString stringWithFormat:@"%d",[str intValue] + 21];
    self.heightArray[tempPath.row] = str;
    
    UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(tempCell.frame.size.width - 250, tempCell.frame.size.height - 1, 250, 20)];
    lab.backgroundColor = MakeRgbColor(230, 230, 240, 1);
    
    lab.textColor = [UIColor grayColor];
    lab.font = [UIFont systemFontOfSize:13];
    lab.text = [NSString stringWithFormat:@"  i say：%@",commentField.text];
    
    [tempCell addSubview:lab];
    
    if (tempLabArray == nil) {
        tempLabArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    [tempLabArray addObject:lab];
    
    [_tableView reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0 && [[commentField.text substringToIndex:1] isEqualToString:@" "]) {
        [MBProgressHUD creatembHub:@"请重新输入"];
        return YES;
    }
    
    NoticeCellModel * mod = self.dataArray[tempPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [AccountRequest addComment:^(NSDictionary *dic) {
        
        [self addComment];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [commentField removeFromSuperview];
        
    } withContentId:mod.contentId withText:textField.text];
    
    return YES;
}

-(void)createRefreshView
{
    header = [MJRefreshHeaderView header];
    footer = [MJRefreshFooterView footer];
    
    __weak NoticeViewController * nvc = self;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refresh)
    {
        [nvc loadData:refresh];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView * refresh)
    {
        [nvc loadData:refresh];
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
        
        
        
    }else
    {
        //下拉加载
        page ++;
    }
    
    [self dataWithPage:page];
}

-(void)dataWithPage:(int)newPage
{
    [AccountRequest getMainList:newPage withSucc:^(NSDictionary *dic)
    {
        NSLog(@"mainlist = %@",dic);
        if (newPage == 1)
        {
            self.dataArray = [NSMutableArray arrayWithCapacity:0];
            
            self.heightArray = [NSMutableArray arrayWithCapacity:0];
        }
        
        if ([dic[@"contentList"] count] == 0) {
            [MBProgressHUD creatembHub:@"已经最底部了"];
            [footer endRefreshing];
            return ;
        }

        
        for (NSDictionary * modDic in dic[@"contentList"]) {
            NoticeCellModel * mod = [[NoticeCellModel alloc]init];
            
            [mod setValuesForKeysWithDictionary:modDic];
            [self.dataArray addObject:mod];
            
            
            NSString * url = mod.firstImg;
            if ([url isEqualToString:@""]) {
                [self.heightArray addObject:[NSString stringWithFormat:@"%f",100.0]];
            }
            else
            {
                [self.heightArray addObject:[NSString stringWithFormat:@"%f",200.0]];
            }
        }
        
        
        if (tempLabArray) {
            for (UILabel * lab in tempLabArray) {
                [lab removeFromSuperview];
            }
        }
        
        [header endRefreshing];
        [footer endRefreshing];
        [_tableView reloadData];
    }];
}

-(ActivityState)stateWithBeginTime:(NSString *)beginTime withEndTime:(NSString *)endTime
{
    if (!beginTime || [beginTime isEqualToString:@""]||!endTime || [endTime isEqualToString:@""])
    {
        return ActivityIsBegining;
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    NSDate *beginDate = [formatter dateFromString:beginTime];
    NSTimeInterval begVal = [beginDate timeIntervalSinceNow];
    
    NSDate * endDate = [formatter dateFromString:endTime];
    NSTimeInterval endVal = [endDate timeIntervalSinceNow];
    
    NSLog(@"begVal = %f,,,,endVal = %f",begVal,endVal);
    
    if (endVal > 0 && begVal < 0) {
        return ActivityIsBegining;
    }
    else if (endVal < 0 && begVal < 0) {
        return ActivityIsOver;
    }
    else
    {
        return ActivityWillBegin;
    }
    
}

-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NoticeActivityCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[NoticeActivityCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        
        if (tempCellArray == nil) {
            tempCellArray = [NSMutableArray arrayWithCapacity:0];
        }
        
        [tempCellArray addObject:cell];
        
        cell.myblock = ^()
        {
            tempCell = cell;
            tempPath = indexPath;
            
            [self btnBlock];
            
        };
    
    }
    
    NoticeCellModel * mod = [[NoticeCellModel alloc]init];
    mod = self.dataArray[indexPath.row];
        
    [cell config:mod];
    
    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeCellModel * mod = self.dataArray[indexPath.row];
    ActivityState state = [self stateWithBeginTime:mod.beginTime withEndTime:mod.endTime];
    
    ActivityViewController * avc = [[ActivityViewController alloc]initWithActivityState:state];
    
    avc.dataModel = mod;
    
    NSLog(@"statr = %d",state);
    
    [self.navigationController pushViewController:avc animated:YES];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [self.heightArray[indexPath.row] floatValue];
    
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
