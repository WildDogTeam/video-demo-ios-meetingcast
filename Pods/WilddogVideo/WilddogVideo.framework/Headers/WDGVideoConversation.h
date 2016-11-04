//
//  WDGClient.h
//  WilddogVideo
//
//  Created by Zheng Li on 8/16/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDGSyncReference;
@class WDGVideoLocalStream;
@class WDGVideoRemoteStream;
@class WDGVideoOutgoingInvite;
@class WDGVideoParticipant;
@protocol WDGVideoConversationDelegate;

/**
 表示 `WDGVideoConversation` 使用的工作模式。
 */
typedef NS_ENUM(NSUInteger, WDGVideoConversationMode) {
    /**
     表示 `P2P` 会话模式
     */
    WDGVideoConversationModeP2P,
    /**
     表示 `Server-based` 会话模式
     */
    WDGVideoConversationModeServerBased
};

NS_ASSUME_NONNULL_BEGIN

/**
 表示加入的会话，同一时间只能加入一个会话。
 */
@interface WDGVideoConversation : NSObject

/**
 表明当前会话使用的模式。
 目前包含 `P2P` 与 `Server-based` 两种模式。
 */
@property (nonatomic, assign, readonly) WDGVideoConversationMode mode;

/**
 表示自己的 Wilddog ID 。
 */
@property (nonatomic, strong, readonly) NSString *participantID;

/**
 表示当前会话的编号。
 */
@property (nonatomic, strong, readonly) NSString *conversationID;

/**
 表示当前视频会话所使用的本地视频、音频流。
 */
@property (nonatomic, strong, readonly) WDGVideoLocalStream *localStream;

/**
 数组中包含除自己外，已加入视频会话参与者。
 */
@property (nonatomic, strong, readonly) NSArray<WDGVideoParticipant *> *participants;

/**
 符合 `WDGVideoConversationDelegate` 协议的代理。
 */
@property (nonatomic, weak, nullable) id<WDGVideoConversationDelegate> delegate;

/**
 邀请其他用户加入当前会话。

 @param participantID 被邀请者的 Wilddog ID 。
 @param error  若邀请未能发出则通过 error 返回原因。

 @return YES 表示邀请成功，NO 表示邀请失败。
 */
- (BOOL)inviteWithParticipantID:(NSString *)participantID error:(NSError * _Nullable * _Nullable)error;

/**
 命令当前会话断开连接。
 */
- (void)disconnect;

/**
 依据会话参与者的 Wilddog ID 获取对应的 `WDGVideoParticipant` 模型。

 @param participantID 会话参与者的 Wilddog ID 。

 @return `WDGVideoParticipant` 实例，若未找到相应参与者，返回 nil 。
 */
- (WDGVideoParticipant * _Nullable)getParticipant:(NSString *)participantID;

@end

/**
 `WDGVideoConversation` 的代理方法。
 */
@protocol WDGVideoConversationDelegate <NSObject>
@optional

/**
 `WDGVideoConversation` 通过调用该方法通知代理当前视频会话有新的参与者加入。

 @param conversation 调用该方法的 `WDGVideoConversation` 实例。
 @param participant  代表新的参与者的 `WDGVideoParticipant` 实例。
 */
- (void)conversation:(WDGVideoConversation *)conversation didConnectParticipant:(WDGVideoParticipant *)participant;

/**
 `WDGVideoConversation` 通过调用该方法通知代理当前视频会话未能与某个参与者建立连接。

 @param conversation 调用该方法的 `WDGVideoConversation` 实例。
 @param participant  代表尝试与其建立连接的参与者的 `WDGVideoParticipant` 实例。
 @param error        表示连接建立失败的原因。
 */
- (void)conversation:(WDGVideoConversation *)conversation didFailToConnectParticipant:(WDGVideoParticipant *)participant error:(NSError *)error;

/**
 `WDGVideoConversation`通过调用该方法通知代理当前视频会话某个参与者断开了连接。

 @param conversation 调用该方法的 `WDGVideoConversation` 实例。
 @param participant  代表已断开连接的参与者的 `WDGVideoParticipant` 实例。
 */
- (void)conversation:(WDGVideoConversation *)conversation didDisconnectParticipant:(WDGVideoParticipant *)participant;

@end

NS_ASSUME_NONNULL_END
