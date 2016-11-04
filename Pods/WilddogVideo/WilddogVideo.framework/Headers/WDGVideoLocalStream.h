//
//  WDGVideoLocalStream.h
//  WilddogVideo
//
//  Created by Zheng Li on 8/23/16.
//  Copyright © 2016 WildDog. All rights reserved.
//

#import "WDGVideoStream.h"

@class WDGVideoConfiguration;

/**
 视频质量选项。
 */
typedef NS_ENUM(NSUInteger, WDGVideoConstraints) {
    /** 
     关闭视频
     */
    WDGVideoConstraintsOff = 0,
    /**
     视频尺寸 352x288
     */
    WDGVideoConstraintsLow,
    /**
     视频尺寸 640x480
     */
    WDGVideoConstraintsStandard,
    /**
     视频尺寸 1280x720
     */
    WDGVideoConstraintsHigh
};

NS_ASSUME_NONNULL_BEGIN

/**
 本地视频流配置。
 */
@interface WDGVideoLocalStreamConfiguration : NSObject

/**
 本地视频流的音频开关。
 */
@property (nonatomic, assign) BOOL audioOn;

/**
 视频质量选项。
 */
@property (nonatomic, assign) WDGVideoConstraints videoOption;

/**
 使用默认配置初始化。默认配置为音频开启，视频质量使用`WDGVideoConstraintsStandard`选项。

 @return `WDGVideoLocalStreamConfiguration`实例。
 */
- (instancetype)init;

/**
 使用指定配置初始化。

 @param videoOption 表明视频的质量。
 @param audioOn     表明是否开启音频。

 @return `WDGVideoLocalStreamConfiguration` 实例。
 */
- (instancetype)initWithVideoOption:(WDGVideoConstraints)videoOption audioOn:(BOOL)audioOn;

@end


/**
 `WDGVideoLocalStream` 继承自 `WDGVideoStream` ，具有 `WDGVideoStream` 所有的方法。
 */
@interface WDGVideoLocalStream : WDGVideoStream

/**
 翻转摄像头。
 */
- (void)flipCamera;

@end

NS_ASSUME_NONNULL_END
