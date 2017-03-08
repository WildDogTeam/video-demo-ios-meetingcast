//
//  RoomViewController.m
//  WilddogVideoDemoMeetingcast
//
//  Created by IMacLi on 16/11/4.
//  Copyright © 2016年 liwuyang. All rights reserved.
//

#import "RoomViewController.h"
#import <WilddogCore/WilddogCore.h>
#import <WilddogSync/WilddogSync.h>
#import <WilddogVideo/WilddogVideo.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "UserListTableViewController.h"

#define conferenceID @"123456"

@interface RoomViewController ()<WDGVideoClientDelegate, WDGVideoConferenceDelegate, WDGVideoMeetingCastDelegate>

@property (weak, nonatomic) IBOutlet UIView *directContainerView;
@property(nonatomic, strong) IJKFFMoviePlayerController *player;//直播播放器对象

@property(nonatomic, strong) WDGSyncReference *wilddog;
@property(nonatomic, strong) WDGVideoClient *wilddogVideoClient;
@property(nonatomic, strong) WDGVideoConference *videoConference;
@property(nonatomic, strong) WDGVideoLocalStream *localStream;
@property (nonatomic, strong) WDGVideoOutgoingInvite *outgoingInvite;
@property (weak, nonatomic) IBOutlet UIButton *liveBtn;
@property(nonatomic, strong) NSMutableArray<WDGVideoRemoteStream *> *remoteStreams;
@property (weak, nonatomic) IBOutlet WDGVideoView *localVideoView;
@property (weak, nonatomic) IBOutlet WDGVideoView *remoteVideoView01;
@property (weak, nonatomic) IBOutlet WDGVideoView *remoteVideoView02;
@property (weak, nonatomic) IBOutlet WDGVideoView *remoteVideoView03;

@property(nonatomic, strong)NSMutableArray *onlineUsers;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = conferenceID;
    self.navigationItem.hidesBackButton = YES;
    self.remoteStreams = [@[] mutableCopy];
    self.wilddog = [[WDGSync sync] reference];

    [self setupWilddogVideoClient];

}

-(void)setupWilddogVideoClient {

    WDGSyncReference *userWilddog = [[self.wilddog child:@"users"] child:self.wDGUser.uid];
    [userWilddog setValue:@YES];
    [userWilddog onDisconnectRemoveValue];

    self.wilddogVideoClient = [[WDGVideoClient alloc] initWithApp:[WDGApp defaultApp]];
    self.wilddogVideoClient.delegate = self;

    [self startPreview];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)appWillEnterForegroundNotification:(NSNotification *)notification{
    WDGSyncReference *userWilddog = [[self.wilddog child:@"users"] child:self.wDGUser.uid];
    [userWilddog setValue:@YES];
    [userWilddog onDisconnectRemoveValue];
}

-(void)startPreview {

#if !TARGET_IPHONE_SIMULATOR
    WDGVideoLocalStreamOptions *localStreamOptions = [[WDGVideoLocalStreamOptions alloc] init];
    localStreamOptions.audioOn = YES;
    localStreamOptions.videoOption = WDGVideoConstraintsHigh;
    // 创建本地媒体流
    self.localStream = [[WDGVideoLocalStream alloc] initWithOptions:localStreamOptions];
#else
    //diable camera controls if on the simulator
#endif
    if (self.localStream) {
        [self.localStream attach:self.localVideoView];
    }

    WDGVideoConnectOptions *connectOptions = [[WDGVideoConnectOptions alloc] initWithLocalStream:self.localStream];
    self.videoConference = [self.wilddogVideoClient connectToConferenceWithID:conferenceID options:connectOptions delegate:self];
}

- (IBAction)clickLivePlay:(UIButton *)sender {

    if (!self.videoConference) {
        [self displayErrorMessage:@"开启视频会议才能直播"];
        return;
    }

    [self.videoConference.meetingCast startWithParticipantID:self.wDGUser.uid];
}

- (IBAction)clickDisconnect:(UIButton *)sender {

    if (self.videoConference) {
        [self.videoConference disconnect];
        self.videoConference = nil;
    }

    if (self.videoConference.meetingCast) {
        [self.videoConference.meetingCast stop];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Display an Error

- (void) displayErrorMessage:(NSString*)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频通话邀请被对方拒绝" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma -mark WDGVideoMeetingCastDelegate

// 随后于 WDGVideoMeetingCastDelegate 方法中获得直播地址
- (void)meetingCast:(WDGVideoMeetingCast *)meetingCast didUpdatedWithStatus:(WDGVideoMeetingCastStatus)status castingParticipantID:(NSString * _Nullable)participantID castURLs:(NSDictionary<NSString *, NSString *> * _Nullable)castURLs {
    NSLog(@"participantID: %@ castURLs: %@", participantID, castURLs);

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    IJKFFOptions *options = [IJKFFOptions optionsByDefault];

    NSURL *url = [NSURL URLWithString:castURLs[@"pull-rtmp-url"]];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.directContainerView.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;

    self.directContainerView.autoresizesSubviews = YES;
    [self.directContainerView addSubview:self.player.view];

    [self.player prepareToPlay];

    [self.liveBtn setTitle:@"断开直播" forState:UIControlStateNormal];
}

- (void)wilddogVideoMeetingCast:(WDGVideoMeetingCast *)MeetingCast didSwitchedToParticipantID:(NSString *)castingParticipantID {
    NSLog(@"%s", __func__);
}


- (void)wilddogVideoMeetingCastDidStopped:(WDGVideoMeetingCast *)MeetingCast {
    NSLog(@"%s", __func__);
    [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

- (void)wilddogVideoMeetingCast:(WDGVideoMeetingCast *)MeetingCast didFailedToChangeCastStatusWithError:(NSError *)error {
    NSLog(@"%s", __func__);
    [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

#pragma -mark WDGVideoConversationDelegate

- (void)conversation:(WDGVideoConversation *)conversation didConnectParticipant:(WDGVideoParticipant *)participant {

    [self.remoteStreams addObject: participant.stream];

    if (1 == self.remoteStreams.count) {
        [self.remoteStreams.lastObject attach:self.remoteVideoView01];
    }else if (2 == self.remoteStreams.count) {
        [self.remoteStreams.lastObject attach:self.remoteVideoView02];
    }else if (3 == self.remoteStreams.count) {
        [self.remoteStreams.lastObject attach:self.remoteVideoView03];
    }

}

- (void)conversation:(WDGVideoConversation *)conversation didFailToConnectParticipant:(WDGVideoParticipant *)participant error:(NSError *)error {

    // 检查是否应该结束会话
    if (self.videoConference.participants.count == 0) {
        [self clickDisconnect:nil];
    }

}

- (void)conversation:(WDGVideoConversation *)conversation didDisconnectParticipant:(WDGVideoParticipant *)participant {

    [UIView animateWithDuration:1 animations:^{
        // 参与者离线，解绑WDGVideoView
        for (NSInteger i = 0; i < self.remoteStreams.count; i++) {
            if (0 == i) {
                [participant.stream detach:self.remoteVideoView01];
            }else if (1 == i) {
                [participant.stream detach:self.remoteVideoView02];
            }else if (2 == i) {
                [participant.stream detach:self.remoteVideoView03];
            }
        }

        [self.remoteStreams removeObject:participant.stream];

        for (NSInteger i = 0; i < self.remoteStreams.count; i++) {
            if (0 == i) {
                [participant.stream attach:self.remoteVideoView01];
            }else if (1 == i) {
                [participant.stream attach:self.remoteVideoView02];
            }else if (2 == i) {
                [participant.stream attach:self.remoteVideoView03];
            }
        }
    }];
    
    // 检查是否应该结束会话
    if (self.videoConference.participants.count == 0) {
        [self clickDisconnect:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
