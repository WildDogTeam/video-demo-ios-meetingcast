//
//  UserListTableViewController.m
//  WilddogVideoDemoMeetingcast
//
//  Created by IMacLi on 16/11/4.
//  Copyright © 2016年 liwuyang. All rights reserved.
//

#import "UserListTableViewController.h"
#import "UserTableViewCell.h"
@interface UserListTableViewController ()
@property (nonatomic, strong) NSMutableArray<NSString *> *users;

@end

@implementation UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.users = [[NSMutableArray<NSString *> alloc] init];

    // 查看当前在线用户
    __weak __typeof__(self) weakSelf = self;
    [[[self.videoReference root] child:@"users"] observeEventType:WDGDataEventTypeValue withBlock:^(WDGDataSnapshot *snapshot) {
        __strong __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }

        NSMutableArray<NSString *> *onlineUsers = [[NSMutableArray<NSString *> alloc] init];

        for (WDGDataSnapshot *aUser in snapshot.children) {
            if (![strongSelf.excludedUsers containsObject:aUser.key]) {
                [onlineUsers addObject:aUser.key];
            }
        }

        strongSelf.users = onlineUsers;
        [strongSelf.tableView reloadData];
    }];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentify = @"userCell";
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    cell.titleLab.text = self.users[indexPath.row];
    __block UserListTableViewController *strongSelf = self;
    cell.clickInviteUserBlock = ^(NSString *title) {
        if (strongSelf.selectedUserBlock) {
            [strongSelf.navigationController popViewControllerAnimated:YES];
            strongSelf.selectedUserBlock(title);
        }
    };

    return cell;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
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
