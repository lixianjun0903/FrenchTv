//
//  TopicViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TopicViewController ()
{
    MPMoviePlayerViewController * play;
}
@property (strong,nonatomic) NSMutableArray * dataArray;
@end

@implementation TopicViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftNav];
    self.title = @"Compte officiel";
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    [self loadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

-(void)movieFinish{
    NSLog(@"1111");
    [play.view removeFromSuperview];
    
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


-(void)loadData
{
    [AccountRequest getTopicList:^(NSDictionary *dataDic) {
        self.topicWriter.text = dataDic[@"contentAuthor"];
        self.topicDate.text = dataDic[@"contentReleaseDate"];
        self.topicTitle.text = dataDic[@"contentTitle"];
        
        self.dataArray = [NSMutableArray arrayWithArray:dataDic[@"contentList"]];
        [_tableView reloadData];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 174;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"TopicCell" owner:self options:nil][0];
    }
    cell.playClickBlock = ^(NSString * videoUrl)
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
    [cell config:self.dataArray[indexPath.row]];
    cell.controller = self;
    return cell;
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
