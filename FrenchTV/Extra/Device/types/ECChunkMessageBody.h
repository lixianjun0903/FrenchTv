//
//  ECChunkMessageBody.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/17.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ECMessageBody.h"

/**
 * chunk消息体类型
 */

@interface ECChunkMessageBody : ECMessageBody
/**
 @property
 @brief 文件消息体的显示名
 */
@property (nonatomic, strong) NSString *displayName;

/**
 @property
 @brief 服务器时间
 */
@property (nonatomic, strong) NSString *serverTime;


/**
 @property
 @brief 文件消息体的本地文件路径
 */
@property (nonatomic, strong) NSString *localPath;

/**
 @property
 @brief 文件消息体的服务器远程文件路径
 */
@property (nonatomic, strong) NSString *remotePath;

/**
 @property
 @brief 文件消息体的文件长度, 以字节为单位
 */
@property (nonatomic) long long fileLength;

/**
 @property
 @brief 语音时长, 秒为单位
 */
@property (nonatomic) NSInteger duration;

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
