//
//  WDGVideoMeetingCastAddon.h
//  WilddogVideo
//
//  Created by Zheng Li on 9/21/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDGVideoConversation;
@protocol WDGVideoMeetingCastAddonDelegate;

/**
 代表当前直播状态
 */
typedef NS_ENUM(NSUInteger, WDGVideoMeetingCastStatus) {
    /**
     *  表示直播未开启或已关闭
     */
    WDGVideoMeetingCastStatusClosed,
    /**
     *  表示直播正在进行中
     */
    WDGVideoMeetingCastStatusOpen,
};

NS_ASSUME_NONNULL_BEGIN

/**
 MeetingCast 插件，用于控制会话的直播状态。通过 `WDGVideoMeetingCastAddonDelegate` 返回直播的拉流地址及直播状态变化情况。
 */
@interface WDGVideoMeetingCastAddon : NSObject

/**
 与直播插件关联的会话实例。
 */
@property (nonatomic, strong, readonly) WDGVideoConversation *conversation;

/**
 表明当前直播的状态。
 */
@property (nonatomic, assign, readonly) WDGVideoMeetingCastStatus meetingCastStatus;

/**
 表明当前正在直播的参与者的 Wilddog ID 。若当前没在直播，该属性为 nil 。
 */
@property (nonatomic, strong, readonly, nullable) NSString *castingParticipantID;

/**
 符合 `WDGVideoMeetingCastAddonDelegate` 协议的代理，负责处理直播相关的事件。
 */
@property (nonatomic, weak, nullable) id<WDGVideoMeetingCastAddonDelegate> delegate;

/**
 开启直播。

 @param participantID 开启直播，并直播 Wilddog ID 为 participantID 的参与者。
 */
- (void)startWithParticipantID:(NSString *)participantID;

/**
 在直播开启后，切换直播视频流。

 @param participantID 直播 Wilddog ID 为 participantID 的参与者。
 */
- (void)switchToParticipantID:(NSString *)participantID;

/**
 关闭直播。
 */
- (void)stop;

@end

/**
 `WDGVideoMeetingCastAddon` 的代理方法。
 */
@protocol WDGVideoMeetingCastAddonDelegate <NSObject>
@optional

/**
 当前会话的直播状态切换为开启直播后，通过该代理方法返回当前直播参与者的 Wilddog ID 与直播流的 URL 地址。

 @param meetingCastAddon     当前 `WDGVideoMeetingCastAddon` 实例。
 @param castingParticipantID 当前直播中的参与者的 Wilddog ID 。
 @param castURLs             包含直播流的 URL 地址，字典的 Key 为直播流的种类，目前包含 `pull-rtmp-url` 和 `pull-hls-url` 两类，字典的 Value 为该直播流种类对应的地址。
 */
- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didStartedWithParticipantID:(NSString *)castingParticipantID castURLs:(NSDictionary<NSString *, NSString *> *)castURLs;

/**
 当前会话的直播状态为开启直播时，若直播的参与者发生了切换，通过该代理方法返回切换后直播参与者的 Wilddog ID 。

 @param meetingCastAddon     当前 `WDGVideoMeetingCastAddon` 实例。
 @param castingParticipantID 切换后直播的参与者的 Wilddog ID 。
 */
- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didSwitchedToParticipantID:(NSString *)castingParticipantID;

/**
 当前会话的直播状态由开启变为关闭后，通过该代理方法返回该状态变化。

 @param meetingCastAddon 当前 `WDGVideoMeetingCastAddon` 实例。
 */
- (void)wilddogVideoMeetingCastAddonDidStopped:(WDGVideoMeetingCastAddon *)meetingCastAddon;

/**
 当直播命令若由于网络等原因失败，通过该代理方法进行处理。

 @param meetingCastAddon 当前 `WDGVideoMeetingCastAddon` 实例。
 @param error            发生的错误详细信息。
 */
- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didFailedToChangeCastStatusWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
