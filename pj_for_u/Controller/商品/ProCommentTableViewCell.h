//
//  ProCommentTableViewCell.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProCommentDetail.h"

@interface ProCommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet YFAsynImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *saleNumber;
@property (strong, nonatomic) IBOutlet UIImageView *starView1;
@property (strong, nonatomic) IBOutlet UIImageView *starView2;
@property (strong, nonatomic) IBOutlet UIImageView *starView3;
@property (strong, nonatomic) IBOutlet UIImageView *starView4;
@property (strong, nonatomic) IBOutlet UIImageView *starView5;

@property (strong, nonatomic) ProCommentDetail *pcd;

@end
