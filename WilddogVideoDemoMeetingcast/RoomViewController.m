//
//  RoomViewController.m
//  WilddogVideoDemoMeetingcast
//
//  Created by IMacLi on 16/11/4.
//  Copyright © 2016年 liwuyang. All rights reserved.
//

#import "RoomViewController.h"
#import <WilddogSync/WilddogSync.h>
#import <WilddogVideo/WilddogVideo.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "UserListTableViewController.h"
@interface RoomViewController ()<WDGVideoClientDelegate, WDGVideoConversationDelegate, WDGVideoMeetingCastAddonDelegate>

@property (weak, nonatomic) IBOutlet UIView *directContainerView;
@property(nonatomic, strong)IJKFFMoviePlayerController *player;//直播播放器对象

@property(nonatomic, strong) WDGSyncReference *wilddog;
@property(nonatomic, strong)WDGVideoClient *wilddogVideoClient;
@property(nonatomic, strong)WDGVideoConversation *videoConversation;
@property(nonatomic, strong)WDGVideoMeetingCastAddon *meetingCastAddon;
@property(nonatomic, strong)WDGVideoLocalStream *localStream;
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

    self.title =  self.wDGUser.uid;
    self.navigationItem.hidesBackButton = YES;
    self.remoteStreams = [@[] mutableCopy];
    self.wilddog = [[WDGSync sync] reference];

    [self setupWilddogVideoClient];

}

-(void)setupWilddogVideoClient {

    WDGSyncReference *userWilddog = [[self.wilddog child:@"users"] child:self.wDGUser.uid];
    [userWilddog setValue:@YES];
    [userWilddog onDisconnectRemoveValue];

    self.wilddogVideoClient = [[WDGVideoClient alloc] initWithSyncReference:@"控制台配置的实时视频交互路径" user:self.wDGUser];//e.g  [self.wilddog child:@"wilddogVideo"]
    self.wilddogVideoClient.delegate = self;

    [self startPreview];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)appWillEnterForegroundNotification:(NSNotification *)notification {
    WDGSyncReference *userWilddog = [[self.wilddog child:@"users"] child:self.wDGUser.uid];
    [userWilddog setValue:@YES];
    [userWilddog onDisconnectRemoveValue];
}

-(void)startPreview {

#if !TARGET_IPHONE_SIMULATOR
    WDGVideoLocalStreamConfiguration *configuration = [[WDGVideoLocalStreamConfiguration alloc] initWithVideoOption:WDGVideoConstraintsStandard audioOn:YES];
    self.localStream = [self.wilddogVideoClient localStreamWithConfiguration:configuration];
#else
    //diable camera controls if on the simulator
#endif
    if (self.localStream) {
        [self.localStream attach:self.localVideoView];
    }

}

- (IBAction)clickInvite:(UIButton *)sender {

    if (self.outgoingInvite == nil) {
        [self performSegueWithIdentifier:@"UserListTableViewController" sender:self];
    } else {
        // 当前正在邀请，取消邀请
        [self.outgoingInvite cancel];
        self.outgoingInvite = nil;
    }

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserListTableViewController"]) {
        // 展示邀请界面，排除当前参与者
        NSMutableArray<NSString *> *excludedUserList = [@[] mutableCopy];
        [excludedUserList addObjectsFromArray:[self.videoConversation.participants valueForKey:@"participantID"]];
        [excludedUserList addObject:self.wDGUser.uid];

        UserListTableViewController *inviteViewController = segue.destinationViewController;
        inviteViewController.excludedUsers = [[NSSet<NSString *> alloc] initWithArray:excludedUserList];
        inviteViewController.videoReference = self.wilddog;
        __weak __typeof(self) weakSelf = self;
        inviteViewController.selectedUserBlock = ^(NSString *userID) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            [strongSelf inviteAUser:userID];
        };
    }
}

- (IBAction)clickLivePlay:(UIButton *)sender {

    if (!self.videoConversation) {
        [self displayErrorMessage:@"开启视频会议才能直播"];
        return;
    }

    if (!self.meetingCastAddon) {
        return;
    }

    if (self.meetingCastAddon.meetingCastStatus == WDGVideoMeetingCastStatusClosed) {
        [self.meetingCastAddon startWithParticipantID:self.wDGUser.uid];
    } else {
        [self.meetingCastAddon stop];
    }

}

- (IBAction)clickDisconnect:(UIButton *)sender {

    if (self.videoConversation) {
        [self.videoConversation disconnect];
        self.videoConversation = nil;
    }

    if (self.meetingCastAddon) {
        [self.meetingCastAddon stop];
        self.meetingCastAddon = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];

}



#pragma mark - Invite a User

-(void)inviteAUser:(NSString *)userID {

    if (!self.videoConversation) {

        __weak __typeof__(self) weakSelf = self;
        self.outgoingInvite = [self.wilddogVideoClient inviteWithParticipantID:userID localStream:self.localStream conversationMode:WDGVideoConversationModeServerBased completion:^(WDGVideoConversation * _Nullable conversation, NSError * _Nullable error) {
            __strong __typeof__(self) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }

            if (error != nil) {
                if ([error.domain isEqualToString:WDGVideoErrorDomain] && error.code == WDGVideoErrorConversationInvitationRejected) {
                    // 对方拒绝邀请
                    NSString *message = [NSString stringWithFormat:@"%@\n拒绝了邀请", userID];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:NULL]];
                    [strongSelf presentViewController:alertController animated:YES completion:NULL];

                    strongSelf.outgoingInvite = nil;
                    return;
                }

                // 其他错误
                strongSelf.outgoingInvite = nil;
                NSLog(@"邀请失败，错误信息: %@", error);
                return;
            }

            strongSelf.videoConversation = conversation;
            strongSelf.videoConversation.delegate = strongSelf;

            if (!strongSelf.meetingCastAddon && strongSelf.videoConversation) {
                strongSelf.meetingCastAddon = [strongSelf.wilddogVideoClient meetingCastAddonWithConversation:strongSelf.videoConversation delegate:strongSelf];
            }
        }];

    } else {

        // 邀请其他用户加入当前会议
        NSError *error = nil;
        if (![self.videoConversation inviteWithParticipantID:userID error:&error]) {

            NSLog(@"未能邀请用户，错误信息：%@", error);

        }

    }

}

#pragma mark - Display an Error

- (void) displayErrorMessage:(NSString*)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频通话邀请被对方拒绝" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma -mark WDGVideoMeetingCastAddonDelegate

- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didStartedWithParticipantID:(NSString *)castingParticipantID castURLs:(NSDictionary<NSString *, NSString *> *)castURLs {
    NSLog(@"castURLs: %@", castURLs);

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    //[IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];

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

- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didSwitchedToParticipantID:(NSString *)castingParticipantID {
    NSLog(@"%s", __func__);
}


- (void)wilddogVideoMeetingCastAddonDidStopped:(WDGVideoMeetingCastAddon *)meetingCastAddon {
    NSLog(@"%s", __func__);
    [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

- (void)wilddogVideoMeetingCastAddon:(WDGVideoMeetingCastAddon *)meetingCastAddon didFailedToChangeCastStatusWithError:(NSError *)error {
    NSLog(@"%s", __func__);
    [self.liveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

#pragma -mark WDGVideoClientDelegate

- (void)wilddogVideoClient:(WDGVideoClient *)videoClient didReceiveInvite:(WDGVideoIncomingInvite *)invite {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@ 邀请你进行视频通话", invite.fromParticipantID] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [invite reject];
    }];

    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __block RoomViewController *strongSelf = self;
        [invite acceptWithCompletion:^(WDGVideoConversation * _Nullable conversation, NSError * _Nullable error) {

            if (error) {
                NSLog(@"error: %@", [error localizedDescription]);
                return ;
            }
            if (!strongSelf.videoConversation) {
                strongSelf.videoConversation = conversation;
                strongSelf.videoConversation.delegate = self;
            }

            if (!strongSelf.meetingCastAddon && strongSelf.videoConversation) {
                strongSelf.meetingCastAddon = [strongSelf.wilddogVideoClient meetingCastAddonWithConversation:strongSelf.videoConversation delegate:strongSelf];
            }

        }];

    }];
    [alertController addAction:rejectAction];
    [alertController addAction:acceptAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)wilddogVideoClient:(WDGVideoClient *)videoClient inviteDidCancel:(WDGVideoIncomingInvite *)invite {

    __weak __typeof__(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        NSString *message = [NSString stringWithFormat:@"%@\n取消了邀请", invite.fromParticipantID];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:NULL]];
        [strongSelf presentViewController:alertController animated:YES completion:NULL];
    }];

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
    if (conversation.participants.count == 0) {
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
    if (conversation.participants.count == 0) {
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
