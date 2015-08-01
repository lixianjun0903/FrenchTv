//
//  DateView.m
//  SportsMatch
//
//  Created by mac on 15/2/20.
//  Copyright (c) 2015年 wsd. All rights reserved.
//

#import "DateView.h"
#import "DateCell.h"

#define MakeRgbColor(r,g,b,a)       [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface DateView ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView * dateView;
    UITableView * tableView;
}
@end

@implementation DateView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createUI:frame];
    }
    return self;
}

-(void)createUI:(CGRect)frame
{
    [self createDateButton];
    [self createTableView:frame];
}

-(void)createTableView:(CGRect)frame
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, frame.size.height - 30) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DateCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DateCell" owner:self options:nil] firstObject];
        
    }
    return cell;
}


-(void)createDateButton
{
    dateView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    dateView.backgroundColor = [UIColor whiteColor];
    [self addSubview:dateView];
    
    NSArray * dateArray = @[@"3-25",@"3-26",@"3-27",@"3-28",@"3-29",@"3-30",@"3-31"];
    for(int i = 0;i < dateArray.count;i++)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = 300 + i;
        
        if(button.tag == 300)
        {
            button.selected = YES;
        }
        
        button.frame = CGRectMake(i * 60, 0 , 60, 30);
        
        [button setTitle:dateArray[i] forState:UIControlStateNormal];
        
        [button setTitleColor:MakeRgbColor(76, 136, 182, 1) forState:UIControlStateSelected];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        [dateView addSubview:button];
    }
    
    dateView.contentSize = CGSizeMake(60 * dateArray.count, 30);
}


@end
