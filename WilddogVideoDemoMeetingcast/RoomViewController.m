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

@interface RoomViewController ()<WDGVideoClientDelegate, WDGVideoConferenceDelegate, WDGVideoMeetingCastDelegate,WDGVideoParticipantDelegate>

@property (weak, nonatomic) IBOutlet UIView *directContainerView;
@property(nonatomic, strong) IJKFFMoviePlayerController *player;//直播播放器对象

@property(nonatomic, strong) WDGSyncReference *wilddog;
@property(nonatomic, strong) WDGVideoClient *wilddogVideoClient;
@property(nonatomic, strong) WDGVideoConference *videoConference;
@property(nonatomic, strong) WDGVideoLocalStream *localStream;
@property(nonatomic, strong) WDGVideoOutgoingInvite *outgoingInvite;
@property(nonatomic, strong) NSMutableArray<WDGVideoRemoteStream *> *remoteStreams;
@property(nonatomic, strong) NSString *otherParticipantID;
@property(nonatomic, strong) NSString *conferenceID;

@property (weak, nonatomic) IBOutlet UIButton *liveBtn;
@property (weak, nonatomic) IBOutlet WDGVideoView *localVideoView;
@property (weak, nonatomic) IBOutlet WDGVideoView *remoteVideoView01;

@property(nonatomic, strong)NSMutableArray *onlineUsers;

@end

@implementation RoomViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"请填写会议 ID" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.conferenceID = alertControl.textFields.firstObject.text;

        self.title = self.conferenceID;
        self.navigationItem.hidesBackButton = YES;
        self.remoteStreams = [@[] mutableCopy];
        self.wilddog = [[WDGSync sync] reference];

        [self setupWilddogVideoClient];
    }]];

    [alertControl addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"会议 ID";
    }];

    [self presentViewController:alertControl animated:YES completion:nil];
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
    self.videoConference = [self.wilddogVideoClient connectToConferenceWithID:self.conferenceID options:connectOptions delegate:self];
}

- (IBAction)clickLivePlay:(UIButton *)sender {

    if (!self.videoConference) {
        [self displayErrorMessage:@"开启视频会议才能直播"];
        return;
    }

    if (self.videoConference.meetingCast.status == WDGVideoMeetingCastStatusOff) {
        self.videoConference.meetingCast.delegate = self;
        [self.videoConference.meetingCast startWithParticipantID:self.wDGUser.uid];
    }else{
        [self.videoConference.meetingCast stop];
    }
}

- (IBAction)switchLivePlay:(id)sender {

    if (self.otherParticipantID.length == 0) {
        return;
    }
    [self.videoConference.meetingCast startWithParticipantID:self.otherParticipantID];
}

- (IBAction)clickDisconnect:(UIButton *)sender {

    if (self.videoConference) {
        [self.videoConference disconnect];
        self.videoConference = nil;
    }

    if (self.videoConference.meetingCast) {
        [self.videoConference.meetingCast stop];
    }

    [self.localStream close];

    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Display an Error

- (void) displayErrorMessage:(NSString*)errorMessage {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma -mark WDGVideoMeetingCastDelegate

// 随后于 WDGVideoMeetingCastDelegate 方法中获得直播地址
- (void)meetingCast:(WDGVideoMeetingCast *)meetingCast didUpdatedWithStatus:(WDGVideoMeetingCastStatus)status castingParticipantID:(NSString * _Nullable)participantID castURLs:(NSDictionary<NSString *, NSString *> * _Nullable)castURLs {

    NSLog(@"participantID: %@ castURLs: %@", participantID, castURLs);

    if (status == WDGVideoMeetingCastStatusOn) {
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

        IJKFFOptions *options = [IJKFFOptions optionsByDefault];

        NSURL *url = [NSURL URLWithString:castURLs[@"rtmp"]];
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.directContainerView.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;

        self.directContainerView.autoresizesSubviews = YES;
        [self.directContainerView addSubview:self.player.view];

        [self.player prepareToPlay];
        
        [self.liveBtn setTitle:@"断开直播" forState:UIControlStateNormal];
    }else{
        [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
}

#pragma mark - WDGVideoParticipantDelegate

- (void)participant:(WDGVideoParticipant *)participant didAddStream:(WDGVideoRemoteStream *)stream
{
    self.otherParticipantID = participant.ID;

    [self.remoteStreams addObject:participant.stream];

    if (1 == self.remoteStreams.count) {
        [self.remoteStreams.lastObject attach:self.remoteVideoView01];
    }
}

#pragma -mark WDGVideoConferenceDelegate

- (void)conference:(WDGVideoConference *)conference didConnectParticipant:(WDGVideoParticipant *)participant{

    participant.delegate = self;
}

- (void)conference:(WDGVideoConference *)conference didFailedToConnectWithError:(NSError *)error{
    // 检查是否应该结束会话
    if (self.videoConference.participants.count == 0) {
        [self clickDisconnect:nil];

        NSLog(@"视频会议连接失败！");
    }
}

- (void)conference:(WDGVideoConference *)conference didDisconnectParticipant:(WDGVideoParticipant *)participant{

    [UIView animateWithDuration:1 animations:^{
        // 参与者离线，解绑WDGVideoView
        for (NSInteger i = 0; i < self.remoteStreams.count; i++) {
            if (0 == i) {
                [participant.stream detach:self.remoteVideoView01];
            }
        }

        [self.remoteStreams removeObject:participant.stream];

        for (NSInteger i = 0; i < self.remoteStreams.count; i++) {
            if (0 == i) {
                [participant.stream attach:self.remoteVideoView01];
            }
        }
    }];
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
