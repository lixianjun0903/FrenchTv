//
//  FavoriteViewController.m
//  FrenchTV
//
//  Created by mac on 15/3/20.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteCell.h"
//#import "FavVideoCell.h"

@interface FavoriteViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic)NSMutableArray * dataArray;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"CancelFav" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLeftNav];
    
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

-(void)loadData
{
    [AccountRequest getFavoriteWithPage:1 withSucc:^(NSDictionary * dataDic) {
        self.dataArray = [NSMutableArray arrayWithArray:dataDic[@"collectList"]];
        [self._tableView reloadData];
        
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.dataArray[indexPath.row][@"type"] isEqualToString:@"video"])
    {
        return 137;
    }else
    {
        return 89;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * normalCell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if(!normalCell)
    {
        normalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    if([self.dataArray[indexPath.row][@"type"] isEqualToString:@"video"])
    {
//        FavVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Video"];
//        if(!cell)
//        {
//            cell = [[NSBundle mainBundle] loadNibNamed:@"FavVideoCell" owner:self options:nil][0];
//        }
//        [cell config:self.dataArray[indexPath.row]];
//        cell.Controller = self;
//        return cell;
    }else
    {
        FavoriteCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Voice"];
        if(!cell)
        {
            cell = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil][0];
        }
        [cell config:self.dataArray[indexPath.row]];
        cell.Controller = self;
        return cell;
        
    }
    
    
    return normalCell;
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
