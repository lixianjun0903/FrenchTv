//
//  ECMediaMessageBody.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/17.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ECMessageBody.h"

/**
 * 附件下载的状态
 */
typedef NS_ENUM(NSUInteger, ECMediaDownloadStatus){
    
    /** 未开始下载 */
	ECMediaUnDownload,
    
    /** 正在下载 */
	ECMediaDownloading,
    
    /** 下载成功 */
	ECMediaDownloadSuccessed,
    
    /** 下载失败 */
	ECMediaDownloadFailure
} ;

/**
 * 附件消息体
 */
@interface ECMediaMessageBody : ECMessageBody
/**
 @brief 文件消息体的显示名
 */
@property (nonatomic, strong) NSString *displayName;

/**
 @brief 服务器时间
 */
@property (nonatomic, strong) NSString *serverTime;

/**
 @brief 文件消息体的本地文件路径
 */
@property (nonatomic, strong) NSString *localPath;

/**
 @brief 文件消息体的服务器远程文件路径
 */
@property (nonatomic, strong) NSString *remotePath;

/**
 @brief 文件消息体的文件长度, 以字节为单位
 */
@property (nonatomic) long long fileLength;

/**
 @brief 语音时长, 秒为单位
 */
@property (nonatomic) NSInteger duration;


/**
 @brief 缩略图本地文件路径
 */
@property (nonatomic, strong) NSString *thumbnailLocalPath;

/**
 @brief 缩略图服务器远程文件路径
 */
@property (nonatomic, strong) NSString *thumbnailRemotePath;

/**
 @brief 附件是否下载完成
 */
@property (nonatomic)ECMediaDownloadStatus mediaDownloadStatus;

/**
 @method
 @brief 以文件路径构造文件对象
 @discussion
 @param filePath 磁盘文件全路径
 @param displayName 文件对象的显示名
 @result 文件对象
 */
- (id)initWithFile:(NSString *)filePath displayName:(NSString *)displayName;

@end
