//
//  WDGVideoInvite.h
//  WilddogVideo
//
//  Created by Zheng Li on 9/6/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDGVideoConversation;

/**
 表示邀请的状态。
 */
typedef NS_ENUM(NSUInteger, WDGVideoInviteStatus)
{
    /**
     *  邀请刚刚被发送或接收
     */
    WDGVideoInviteStatusPending = 0,

    /**
     *  被邀请方接受邀请
     */
    WDGVideoInviteStatusAccepting,

    /**
     *  邀请方确认邀请被接收，双方建立会话
     */
    WDGVideoInviteStatusAccepted,

    /**
     *  邀请被本地客户端拒绝
     */
    WDGVideoInviteStatusRejected,

    /**
     *  邀请被邀请方撤销
     */
    WDGVideoInviteStatusCancelled,

    /**
     *  邀请被接受但无法建立会话
     */
    WDGVideoInviteStatusFailed
};

/**
 当邀请方的邀请得到回应后，SDK 通过该格式的闭包通知开发者处理邀请结果。

 @param conversation `WDGVideoConversation` 实例，当邀请成功后，SDK 创建 `WDGVideoConversation` 实例，邀请失败时，该值为 nil 。
 @param error        `NSError` 实例，当邀请由于某种原因失败时，如邀请被被邀请方拒绝时，SDK 返回错误信息让开发者处理。邀请成功时改值为 nil 。
 */
typedef void (^WDGVideoInviteAcceptanceBlock)(WDGVideoConversation * _Nullable conversation, NSError * _Nullable error);
