//
//  ECError.h
//  CCPiPhoneSDK
//
//  Created by jiazy on 14/11/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 错误类型枚举值
 */
typedef NS_ENUM(NSInteger,ECErrorType) {
    
    /** 无错误，成功 */
    ECErrorType_NoError = 0,
    
    /** 解析xml异常 */
    ECErrorType_XmlError=170000,
    
    /** 内容长度超过规定 */
    ECErrorType_ContentTooLong,
    
    /** 必选参数为空 */
    ECErrorType_IsEmpty,
    
    /** 未登录 */
    ECErrorType_NotLogin,
    
    /** 发送消息失败 */
    ECErrorType_SendMsgFailed,  //
    
    /** 正在录音，当前只能录制一个，请先停止 */
    ECErrorType_IsRecording,    //
    
    /** 录音超时，60秒长度 */
    ECErrorType_RecordTimeOut,  //
    
    /** 录音已经停止，当前未录音调用停止录音 */
    ECErrorType_RecordStoped,   //
    
    /** 录音时间过短，不超过1秒 */
    ECErrorType_RecordTimeTooShort, //
    
    /** 发送附件消息，上传文件失败 */
    ECErrorType_UploadFailed,   //
    
    /** chunk模式下，对方取消发送语音 */
    ECErrorType_UploadCancel,   //
    
    /** 文件不存在 */
    ECErrorType_FileNotExist,   //
    
    /** 传入的参数类型错误 */
    ECErrorType_TypeIsWrong,    //
    
#pragma mark - 网络请求错误码
    /** 创建网络连接失败 */
    ECErrorType_HttpConnectionFailure,//
    
    /** 网络请求超时 */
    ECErrorType_HttpRequestTimedOut,//
    
    /** 网络认证失败 */
    ECErrorType_HttpAuthentication,//
    
    /** 请求已经被取消 */
    ECErrorType_HttpRequestCancelled,//
    
    /** 未能创建请求 */
    ECErrorType_HttpUnableToCreateRequest,//
    
    /** 创建请求中网络错误 */
    ECErrorType_HttpInternalErrorWhileBuildingRequest,//
    
    /** 申请证书时网络错误 */
    ECErrorType_HttpInternalErrorWhileApplyingCredentials,//
    
    /** 文件操作错误 */
    ECErrorType_HttpFileManagement,//
    
    /** 网络中过多重定向 */
    ECErrorType_HttpTooMuchRedirection,//
    
    /** 其他网络异常 */
    ECErrorType_HttpUnhandledException,//
    
#pragma mark - 175消息错误
    ECErrorType_NoResponse=175001,
    ECErrorType_BadCredentials,
    ECErrorType_ReFetchSoftSwitch,
    ECErrorType_KickedOff,
    ECErrorType_CalleeNoVoip,
    ECErrorType_InvalidProxy,
    ECErrorType_NoNetwork,
    
    ECErrorType_Trying = 175100,
    ECErrorType_Ringing = 175180,
    ECErrorType_CallIsBeingForwarded = 175181,
    ECErrorType_Queued = 175182,
    ECErrorType_SessionProgress = 175183,
    ECErrorType_OK = 175200,
    ECErrorType_Accepted = 175202,
    ECErrorType_MultipleChoices = 175300,
    ECErrorType_MovedPermanently = 175301,
    ECErrorType_MovedTemporarily = 175302,
    ECErrorType_UseProxy = 175305,
    ECErrorType_AlternativeService = 175380,
    ECErrorType_BadRequest = 175400,
    ECErrorType_Unauthorized = 175401,
    ECErrorType_PaymentRequired = 175402,
    ECErrorType_Forbidden = 175403,
    ECErrorType_NotFound = 175404,
    ECErrorType_MethodNotAllowed = 175405,
    ECErrorType_NotAcceptable = 175406,
    ECErrorType_ProxyAuthenticationRequired = 175407,
    ECErrorType_Timeout = 175408,
    ECErrorType_CallMissed=175409,
    ECErrorType_Gone = 175410,
    ECErrorType_LengthRequired = 175411,
    ECErrorType_ConditionalRequestFailed = 175412,
    ECErrorType_RequestEntityTooLarge = 175413,
    ECErrorType_RequestUriTooLarge = 175414,
    ECErrorType_UnsupportedMediaType = 175415,
    ECErrorType_UnsupportedUriScheme = 175416,
    ECErrorType_BadExtension = 175420,
    ECErrorType_ExtensionRequired = 175421,
    ECErrorType_SessionIntervalTooSmall = 175422,
    ECErrorType_IntervalTooShort = 175423,
    ECErrorType_NotSupportVoip = 175430,
    ECErrorType_TemporarilyNotAvailable = 175480,
    ECErrorType_CallLegOrTransactionDoesNotExist = 175481,
    ECErrorType_LoopDetected = 175482,
    ECErrorType_TooManyHops = 175483,
    ECErrorType_AddressIncomplete = 175484,
    ECErrorType_Ambiguous = 175485,
    ECErrorType_CallBusy = 175486,
    ECErrorType_RequestCancelled = 175487,
    ECErrorType_NotAcceptableHere = 175488,
    ECErrorType_BadEvent = 175489,
    ECErrorType_RequestPending = 175491,
    ECErrorType_Undecipherable = 175493,
    ECErrorType_InternalServerError = 175500,
    ECErrorType_NotImplemented = 175501,
    ECErrorType_BadGateway = 175502,
    ECErrorType_ServiceUnavailable = 175503,
    ECErrorType_GatewayTimeOut = 175504,
    ECErrorType_SIPVersionNotSupported = 175505,
    ECErrorType_BusyEverywhere = 175600,
    ECErrorType_Declined = 175603,
    ECErrorType_DoesNotExistAnywhere = 175604,
    ECErrorType_NotAcceptableAnywhere = 175606
    
};

/**
 * 错误类
 */
@interface ECError : NSObject

/**
 @property
 @brief 错误类型
 */
@property (nonatomic, readonly) ECErrorType errorCode;

/**
 @property
 @brief 错误类型描述
 */
@property (nonatomic, copy) NSString *errorDescription;

/**
 @param errorCode 错误类型
 @return 错误
 */

+ (ECError *)errorWithCode:(ECErrorType)errorCode;

/**
 @param error 错误
 @return 错误
 */
+ (ECError *)errorWithNSError:(NSError *)error;

@end
