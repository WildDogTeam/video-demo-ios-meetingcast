//
//  UserTableViewCell.m
//  WilddogVideoDemoMeetingcast
//
//  Created by IMacLi on 16/11/4.
//  Copyright © 2016年 liwuyang. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickInviteBtn:(id)sender {
    if (self.clickInviteUserBlock) {
        self.clickInviteUserBlock(self.titleLab.text);
    }
}
@end
