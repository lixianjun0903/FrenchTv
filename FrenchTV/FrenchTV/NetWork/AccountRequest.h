//
//  RegisterRequest.h
//  FrenchTV
//
//  Created by mac on 15/2/9.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountRequest : NSObject

//注册
+(void)RegisterRequestWithUserName:(NSString *)username PassWord:(NSString *)password withAccountName:(NSString *)accountName succ:(void (^)(NSDictionary *))succ;
//登陆
+(void)LoginRequestWithUserName:(NSString *)username PassWord:(NSString *)password succ:(void (^)(NSDictionary * data))succ;
//获取主持人列表
+(void)getHostListRequestWithSucc:(void (^)(NSArray * data))succ;
//通过voip账号获取用户信息
+(void)getUserInfo:(void(^)(NSDictionary * UserInfo))succ WithUserVoip:(NSString *)voip;

//获取专题列表
+(void)getTopicList:(void(^)(NSDictionary * dataDic))succ;

//主账户内容列表
+(void)getMainList:(int)pageNo withSucc:(void (^)(NSDictionary *))succ;

//获取广播接口
+(void)getAudioInfo:(void (^)(NSDictionary *))succ;

+(void)getHostNews:(void(^)(NSDictionary * HostNews))succ WithHostId:(int)ID;

//修改昵称
+(void)AccountChangeName:(void(^)(NSDictionary * dic))succ withNewName:(NSString *)newName;

//获取活动留言列表
+(void)getActivityComment:(void(^)(NSDictionary * dic))succ withContentId:(int)contentId withPage:(int)pageNo;

//添加评论
+(void)addComment:(void(^)(NSDictionary * dic))succ withContentId:(int)contentId withText:(NSString *)text;

//用户反馈
+(void)accountFeedBackWithText:(NSString *)text withMail:(NSString *)mail withPhoneNum:(NSString *)numStr withSucc:(void (^)(NSDictionary *))succ;

//上传头像
+(void)accountChangeHeaderWithUserId:(int)userId withImgName:(NSString *)imgName withImage:(UIImage *)userIcon withSucc:(void (^)(NSDictionary *))succ;
//中文课堂发送信息
+(void)LessonSendWord:(NSString *)word withSucc:(void (^)(NSDictionary *))succ;

//中文课堂
+(void)getChineseClass:(void (^)(NSDictionary *))succ;
//提交主持人投票
+(void)commitHostVote:(void (^)(NSDictionary *))succ WithTopicId:(int)topID WithitemID:(int)itemId WithHostId:(int)hostId;

//获取介绍
+(void)getIntroduce:(void (^)(NSDictionary *))succ;

//获取收藏
+(void)getFavoriteWithPage:(int)page withSucc:(void (^)(NSDictionary *))succ;

//添加收藏
+(void)addFavoriteWithId:(int)contentId withSucc:(void (^)(NSDictionary *))succ;

//删除收藏
+(void)deleteFavoriteWithId:(int)contentId withSucc:(void (^)(NSDictionary *))succ;
//搜索功能
+(void)accountSearchWithWord:(NSString * )word withSucc:(void (^)(NSDictionary *))succ;

//主持人发布公共语音
+(void)hostSendVoice:(NSData *)Voicedata withSucc:(void (^)(NSDictionary *))succ fail:(void (^)(NSError * err))fail;
//文件下载
+(BOOL)downLoadFileWithUrl:(NSString *)url withSucc:(void (^)(ECMediaMessageBody *))succ;

//修改密码
+(void)accountChangePasswordWithOld:(NSString*)oldP withNew:(NSString *)newP withSucc:(void (^)(NSDictionary *))succ;

@end
