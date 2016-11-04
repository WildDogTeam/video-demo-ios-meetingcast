//
//  WDGVideoIncomingInvite.h
//  WilddogVideo
//
//  Created by Zheng Li on 8/24/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDGVideoInvite.h"

@class WDGVideoConversation;
@class WDGVideoLocalStream;

NS_ASSUME_NONNULL_BEGIN

/**
 表示来自其它用户的会话邀请。
 */
@interface WDGVideoIncomingInvite : NSObject

/**
 邀请者的 Wilddog ID ，表明这个邀请来自哪个用户。
 */
@property (nonatomic, strong, readonly) NSString *fromParticipantID;

/**
 表示邀请参加的会议的编号。
 */
@property (nonatomic, strong, readonly) NSString *conversationID;

/**
 表示当前邀请的状态。
 */
@property (nonatomic, assign, readonly) WDGVideoInviteStatus status;

/**
 接受邀请，使用当前本地视频流接受邀请，并在`completionHandler`中返回结果。若当前未创建本地视频流，将自动以默认配置创建本地视频流。

 @param completionHandler 当邀请得到确认后，SDK通过该闭包通知邀请结果，若邀请成功，将在闭包中返回`WDGVideoConversation`实例，否则将在闭包中返回`NSError`说明邀请失败的原因。
 */
- (void)acceptWithCompletion:(WDGVideoInviteAcceptanceBlock)completionHandler;

/**
 接受邀请，使用指定视频流接受邀请，并在`completionHandler`中返回结果。

 @param localStream       想要使用的视频流。
 @param completionHandler 当邀请得到确认后，SDK通过该闭包通知邀请结果，若邀请成功，将在闭包中返回`WDGVideoConversation`实例，否则将在闭包中返回`NSError`说明邀请失败的原因。
 */
- (void)acceptWithLocalStream:(WDGVideoLocalStream *)localStream
                   completion:(WDGVideoInviteAcceptanceBlock)completionHandler;

/**
 调用此方法拒绝邀请。
 */
- (void)reject;

@end

NS_ASSUME_NONNULL_END
