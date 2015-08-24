//
//  BigManageTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/8/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigManageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *togetherDate;
@property (strong, nonatomic) IBOutlet UILabel *togetherId;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *reserveTime;
@property (strong, nonatomic) IBOutlet UILabel *adminName;

@end
