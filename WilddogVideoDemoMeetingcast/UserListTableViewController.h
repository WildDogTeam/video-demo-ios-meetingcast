//
//  UserListTableViewController.h
//  WilddogVideoDemoMeetingcast
//
//  Created by IMacLi on 16/11/4.
//  Copyright © 2016年 liwuyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WilddogSync/WilddogSync.h>
typedef void (^selectedUser)(NSString *user);
@interface UserListTableViewController : UITableViewController

@property (nonatomic, strong) NSSet<NSString *> *excludedUsers;
@property(nonatomic, strong) WDGSyncReference *videoReference;
@property(nonatomic, strong) selectedUser selectedUserBlock;

@end
