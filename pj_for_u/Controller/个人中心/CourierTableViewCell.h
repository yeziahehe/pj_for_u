//
//  CourierTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/8/25.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourierTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *togetherDate;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *customePhone;
@property (strong, nonatomic) IBOutlet UILabel *togetherId;
@property (strong, nonatomic) IBOutlet UILabel *nickName;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UILabel *reserveTime;
@property (strong, nonatomic) IBOutlet UILabel *message;

@property (strong, nonatomic) NSArray *orderList;
@property (strong, nonatomic) NSIndexPath *itsIndexPath;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) void (^callUsersPhone)();
@end
