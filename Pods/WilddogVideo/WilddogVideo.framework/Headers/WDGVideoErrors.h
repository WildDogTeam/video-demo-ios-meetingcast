//
//  WDGVideoErrors.h
//  WilddogVideo
//
//  Created by Zheng Li on 9/8/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_attribute(ns_error_domain) && (!__cplusplus || __cplusplus >= 201103L)
#define WDG_ERROR_ENUM(type, name, domain) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
    NS_ENUM(type, __attribute__((ns_error_domain(domain))) name) \
    _Pragma("clang diagnostic pop")
#else
#define WDG_ERROR_ENUM(type, name, domain) NS_ENUM(type, name)
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WDGVideoErrorDomain;

/**
 WilddogVideo 使用的错误码。
 */
typedef WDG_ERROR_ENUM(NSInteger, WDGVideoError, WDGVideoErrorDomain)
{
    /**
     输入参数无效
     @note: 详细信息见 `localizedDescription` 字段。
     */
    WDGVideoErrorInvalidArgument = 40001,

    /**
     无摄像头或麦克风权限
     */
    WDGVideoErrorDeviceNotAvailable = 40002,

    /**
     Client初始化失败，Video 功能未开启
     */
    WDGVideoErrorClientRegistrationFailed = 40100,

    /**
     Client初始化失败，Auth token 过期
     */
    WDGVideoErrorInvalidAuthArgument = 40101,

    /**
     Client初始化失败，Sync 对象无效
     */
    WDGVideoErrorInvalidSyncArgument = 40102,

    /**
     媒体流无效
     */
    WDGVideoErrorInvalidStreamState = 40103,

    /**
     无法以该会话模式发起会话，未开启该会话模式
     */
    WDGVideoErrorInvalidConversationMode = 40104,

    /**
     会话人数超过上限
     */
    WDGVideoErrorTooManyParticipants = 40200,

    /**
     会话邀请发起失败
     */
    WDGVideoErrorConversationInvitationFailed = 40201,

    /**
     会话邀请被拒绝
     */
    WDGVideoErrorConversationInvitationRejected = 40202,

    /**
     被邀请者繁忙，不能响应邀请
     */
    WDGVideoErrorConversationInvitationIgnored = 40203,

    /**
     无法与参与者建立连接
     */
    WDGVideoErrorParticipantConnectionFailed = 40204,

    /**
     会话数超过上限
     */
    WDGVideoErrorTooManyActiveConversations = 40205,

    /**
     MeetingCast 初始化失败，未在控制面板中开启功能
     */
    WDGVideoErrorMeetingCastRegistrationFailed = 40310,

    /**
     MeetingCast 操作冲突，当前已经开启 MeetingCast
     */
    WDGVideoErrorMeetingCastStartFailed = 40311,

    /**
     MeetingCast 切换参与者失败，未开启 MeetingCast 或切换失败。
     */
    WDGVideoErrorMeetingCastSwitchFailed = 40312,

};

NS_ASSUME_NONNULL_END
