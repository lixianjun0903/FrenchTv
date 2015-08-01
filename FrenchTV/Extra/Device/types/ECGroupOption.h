//
//  ECGroupOption.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/7.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 群组规则
 */
@interface ECGroupOption : NSObject
/**
 @brief groupId 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 @brief rule 接收规则 0接收 1拒绝
 */
@property (nonatomic, assign) NSInteger rule;
@end
