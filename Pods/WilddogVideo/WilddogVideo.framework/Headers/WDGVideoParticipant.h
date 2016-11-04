//
//  WDGVideoParticipant.h
//  WilddogVideo
//
//  Created by Zheng Li on 9/8/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDGVideoRemoteStream;

NS_ASSUME_NONNULL_BEGIN

/**
 代表会话的参与者。
 */
@interface WDGVideoParticipant : NSObject

/**
 当前参与者的 Wilddog ID 。
 */
@property (nonatomic, strong, readonly) NSString *participantID;

/**
 当前参与者发布的视频、音频流。
 */
@property (nonatomic, strong, readonly, nullable) WDGVideoRemoteStream *stream;

@end

NS_ASSUME_NONNULL_END
