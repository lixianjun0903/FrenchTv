/**
 @header ECGroupNoticeMessage.h
 @abstract 群组通知回调事件的类说明
 */

#import <Foundation/Foundation.h>

/**
 * 群组通知消息类型枚举
 */
typedef NS_ENUM(NSUInteger, ECGroupMessageType) {
    
    /** 群组解散 */
    ECGroupMessageType_Dissmiss,
    
    /** 邀请加入 */
    ECGroupMessageType_Invite,
    
    /** 申请加入 */
    ECGroupMessageType_Propose,
    
    /** 加入群组 */
    ECGroupMessageType_Join,
    
    /** 退出群组 */
    ECGroupMessageType_Quit,
    
    /** 提出成员 */
    ECGroupMessageType_RemoveMember,
    
    /** 验证邀请 */
    ECGroupMessageType_ReplyInvite,
    
    /** 验证加入 */
    ECGroupMessageType_ReplyJoin
};


/**
 * 群组通知消息基类
 */
@interface ECGroupNoticeMessage : NSObject
/**
 @brief 群组ID
 */
@property (nonatomic, retain) NSString *groupId;
/**
 @brief 群组类型
 */
@property (nonatomic, readonly) ECGroupMessageType messageType;
/**
 @brief 消息时间
 */
@property (nonatomic, retain) NSString *dateCreated;
/**
 @brief 是否已读
 */
@property (nonatomic, assign) BOOL isRead;
@end


/**
 * 解散群组
 */
@interface ECDismissGroupMsg : ECGroupNoticeMessage
@end


/**
 * 收到邀请
 */
@interface ECInviterMsg : ECGroupNoticeMessage
/**
 @brief 管理员
 */
@property (nonatomic, retain) NSString *admin;
/**
 @brief 邀请理由
 */
@property (nonatomic, retain) NSString *declared;
/**
 @brief 是否需要验证 0需要确认 1不需要确认
 */
@property (nonatomic, assign) NSInteger confirm;
@end

/**
 * 收到申请
 */
@interface ECProposerMsg : ECGroupNoticeMessage
/**
 @brief 申请者
 */
@property (nonatomic, retain) NSString *proposer;
/**
 @brief 申请理由
 */
@property (nonatomic, retain) NSString *declared;
@end

/**
 * 有成员加入
 */
@interface ECJoinGroupMsg : ECGroupNoticeMessage
/**
 @brief 加入成员
 */
@property (nonatomic, retain) NSString *member;
/**
 @brief
 */
@property (nonatomic, retain) NSString *declared;
@end

/**
 * 退出群组
 */
@interface ECQuitGroupMsg : ECGroupNoticeMessage
/**
 @brief 退出的成员
 */
@property (nonatomic, retain) NSString *member;
@end


/**
 * 移除成员
 */
@interface ECRemoveMemberMsg : ECGroupNoticeMessage
/**
 @brief 移除的成员
 */
@property (nonatomic, retain) NSString *member;
@end

/**
 * 答复申请加入
 */
@interface ECReplyJoinGroupMsg : ECGroupNoticeMessage
/**
 @brief 管理员
 */
@property (nonatomic, retain) NSString *admin;
/**
 @brief 是否需要验证 0需要确认 1不需要确认
 */
@property (nonatomic, assign) NSInteger confirm;
/**
 @brief 加入的成员
 */
@property (nonatomic, retain) NSString *member;
@end

/**
 * 答复邀请加入
 */
@interface ECReplyInviteGroupMsg : ECGroupNoticeMessage
/**
 @brief 管理员
 */
@property (nonatomic, retain) NSString *admin;
/**
 @brief 是否需要验证 0需要确认 1不需要确认
 */
@property (nonatomic, assign) NSInteger confirm;
/**
 @brief 加入的成员
 */
@property (nonatomic, retain) NSString *member;
@end

