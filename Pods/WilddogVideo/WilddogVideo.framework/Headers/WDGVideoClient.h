//
//  WDGVideo.h
//  WilddogVideo
//
//  Created by Zheng Li on 8/19/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDGVideoInvite.h"
#import "WDGVideoConversation.h"

@class WDGSyncReference;
@class WDGUser;
@class WDGVideoConversation;
@class WDGVideoIncomingInvite;
@class WDGVideoOutgoingInvite;
@class WDGVideoLocalStream;
@class WDGVideoLocalStreamConfiguration;
@class WDGVideoMeetingCastAddon;
@protocol WDGVideoClientDelegate;
@protocol WDGVideoMeetingCastAddonDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 用于创建本地流，发起会话。
 */
@interface WDGVideoClient : NSObject

/**
 符合 `WDGVideoClientDelegate` 协议的代理，用于处理视频会话邀请消息。
 */
@property (nonatomic, weak, nullable) id<WDGVideoClientDelegate> delegate;


/**
 Client 的 Wilddog ID 。
 */
@property (nonatomic,strong, readonly) NSString *uid;


/**
 继承自NSObject的初始化方法不可用。

 @return 无效的 `WDGVideoClient` 实例。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 初始化 `WDGVideoClient` 实例。初始化时会从野狗服务器获取控制台配置信息，若控制台未开启实时视频功能，则返回 nil 。

 @param syncReference 用于数据交换的 `WilddogSync` 节点。如果后面使用 `Server-based` 模式建立会话，需要保证该路径和控制面板中的交互路径一致。
 @param user          代表已登录用户的 `WDGUser` 实例。

 @return `WDGVideoClient` 实例，若初始化失败返回nil。
 */
- (nullable instancetype)initWithSyncReference:(WDGSyncReference *)syncReference user:(WDGUser *)user NS_DESIGNATED_INITIALIZER;

/**
 邀请其他用户进行视频会话。创建会话时使用指定的本地视频流。

 @param participantID     被邀请者的 Wilddog ID 。
 @param localStream       邀请成功时使用该视频流创建会话。
 @param conversationMode  视频会话的通信模式，分为 `P2P` 和 `Server-based` 两种模式。若要使用 `Server-based` 模式，需在野狗控制台中开启服务器中转功能，同时配置交互路径和超级密钥。
 @param completionHandler 当邀请得到回应后，SDK 通过该闭包通知邀请结果，若对方接受邀请，将以默认配置创建本地流，并在闭包中返回 `WDGVideoConversation` 实例，否则将在闭包中返回 `NSError` 说明邀请失败的原因。

 @return `WDGVideoOutgoingInvite` 实例，可用于取消此次邀请。
 */
- (WDGVideoOutgoingInvite * _Nullable)inviteWithParticipantID:(NSString *)participantID localStream:(WDGVideoLocalStream *)localStream conversationMode:(WDGVideoConversationMode)conversationMode completion:(WDGVideoInviteAcceptanceBlock)completionHandler;

/**
 依照配置创建一个本地视频流。同一时刻只能存在一个本地视频流，若此时已经创建其他视频流，会自动将其他视频流关闭。

 @param configuration `WDGVideoLocalStreamConfiguration` 实例。

 @return 创建的本地视频流 `WDGVideoLocalStream` 实例。
 */
- (WDGVideoLocalStream *)localStreamWithConfiguration:(WDGVideoLocalStreamConfiguration *)configuration;

/**
 创建直播插件，直播插件只适用于 `Server-based` 模式的会话，通过直播插件查看并控制当前视频会话的直播状态。

 @param conversation 需要进行直播的会话，该会话必须为 `Server-based` 模式。
 @param delegate     符合 `WDGVideoMeetingCastAddonDelegate` 的代理，用于处理直播状态变更消息。

 @return `WDGVideoMeetingCastAddon` 实例。
 */
- (WDGVideoMeetingCastAddon * _Nullable)meetingCastAddonWithConversation:(WDGVideoConversation *)conversation delegate:(id<WDGVideoMeetingCastAddonDelegate>)delegate;

@end

/**
 `WDGVideoClient` 的代理方法。
 */
@protocol WDGVideoClientDelegate <NSObject>
@optional

/**
 `WDGVideoClient` 通过调用该方法通知当前用户收到新的视频会话邀请。

 @param videoClient 调用该方法的 `WDGVideoClient` 实例。
 @param invite      代表收到的邀请的 `WDGVideoIncomingInvite` 实例。
 */
- (void)wilddogVideoClient:(WDGVideoClient *)videoClient didReceiveInvite:(WDGVideoIncomingInvite *)invite;

/**
 `WDGVideoClient` 通过调用该方法通知当前用户之前收到的某个邀请被邀请者取消。

 @param videoClient 调用该方法的 `WDGVideoClient` 实例。
 @param invite      代表被取消的邀请的 `WDGVideoIncomingInvite` 实例。
 */
- (void)wilddogVideoClient:(WDGVideoClient *)videoClient inviteDidCancel:(WDGVideoIncomingInvite *)invite;

@end

NS_ASSUME_NONNULL_END
