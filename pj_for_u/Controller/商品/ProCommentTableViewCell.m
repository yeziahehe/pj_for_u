//
//  ProCommentTableViewCell.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProCommentTableViewCell.h"

@implementation ProCommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setPcd:(ProCommentDetail *)pcd{
    _pcd = pcd;
    
    self.nickNameLabel.text = pcd.nickName;
    self.gradeLabel.text = pcd.grade;
    self.timeLabel.text = pcd.date;
    self.saleNumber.text = pcd.orderCount;
    self.commentLabel.text = pcd.comment;
    self.userImage.cacheDir = kUserIconCacheDir;
    [self.userImage aysnLoadImageWithUrl:pcd.imgUrl placeHolder:@"icon_user_default.png"];
}

@end
