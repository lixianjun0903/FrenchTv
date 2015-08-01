//
//  ECGroupMatch.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/7.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 群组搜索的条件
 */
@interface ECGroupMatch : NSObject

/**
 @property
 @brief groupId 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 @property
 @brief name 群组名称
 */
@property (nonatomic, copy) NSString *groupName;
@end
