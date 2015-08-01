//
//  NoticeCellModel.h
//  FrenchTV
//
//  Created by gaobo on 15/3/6.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoticeCellModel : NSObject


@property (nonatomic) int contentId;
@property (strong, nonatomic) NSString *beginTime;
@property (strong, nonatomic) NSString *contentChannel;
@property (strong, nonatomic) NSString *contentTitle;
@property (strong, nonatomic) NSString *contentTxt;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *firstImg;
@property (strong, nonatomic) NSString *imgTxt;
@property (strong, nonatomic) NSString *contentModel;
@property (strong, nonatomic) NSArray *imgList;
@property (strong, nonatomic) NSString * contentReleaseDate;
@property (strong, nonatomic) NSString * contentMediaPath;
@property (strong, nonatomic) NSString * contentAbstract;

@end
