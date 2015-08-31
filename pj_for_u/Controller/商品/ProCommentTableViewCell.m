//
//  ProCommentTableViewCell.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProCommentTableViewCell.h"

@implementation ProCommentTableViewCell

#pragma mark - UIView Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - Set Methods
-(void)setPcd:(ProCommentDetail *)pcd
{
    _pcd = pcd;
    
    self.userImage.cacheDir = kUserIconCacheDir;
    if ([pcd.isHidden isEqualToString:@"1"]) {
        self.nickNameLabel.text = @"匿名用户";
        [self.userImage aysnLoadImageWithUrl:nil placeHolder:@"icon_user_default.png"];
    } else {
        self.nickNameLabel.text = pcd.nickName;
        [self.userImage aysnLoadImageWithUrl:pcd.imgUrl placeHolder:@"icon_user_default.png"];
    }
    
    self.gradeLabel.text = [NSString stringWithFormat:@"%@分",pcd.grade];
    self.timeLabel.text = pcd.date;
    self.saleNumber.text = [NSString stringWithFormat:@"销量：%@",pcd.orderCount];
    self.commentLabel.text = pcd.comment;
    
    if ([pcd.grade intValue]) {
        [self lightStars];
    }
}

#pragma mark - Private Methods
-(void)lightStars
{
    NSInteger grade = [self.pcd.grade intValue];
    if (grade > 4) {
        [self.starView5 setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"]];
    }
    if (grade > 3) {
        [self.starView4 setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"]];
    }
    if (grade > 2) {
        [self.starView3 setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"]];
    }
    if (grade > 1) {
        [self.starView2 setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"]];
    }
    if (grade > 0) {
        [self.starView1 setImage:[UIImage imageNamed:@"icon_evaluationStarLight.png"]];
    }
}

@end
