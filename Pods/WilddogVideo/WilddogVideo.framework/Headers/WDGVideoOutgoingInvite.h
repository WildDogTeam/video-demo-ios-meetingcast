//
//  WDGVideoOutgoingInvite.h
//  WilddogVideo
//
//  Created by Zheng Li on 8/24/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDGVideoInvite.h"

@class WDGSyncReference;

NS_ASSUME_NONNULL_BEGIN

/**
 表示自己发出的会话邀请。
 */
@interface WDGVideoOutgoingInvite : NSObject

/**
 被邀请者的 Wilddog ID 。
 */
@property (nonatomic, strong, readonly) NSString *toParticipantID;

/**
 表示邀请参加的会议的编号。
 */
@property (nonatomic, strong, readonly) NSString *conversationID;

/**
 表示当前邀请的状态。
 */
@property (nonatomic, assign, readonly) WDGVideoInviteStatus status;

/**
 调用此方法取消当前邀请。
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
