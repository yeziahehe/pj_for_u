//
//  MyOrderTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *togetherDate;
@property (strong, nonatomic) IBOutlet UILabel *orderType;
@property (strong, nonatomic) IBOutlet UILabel *totalConut;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *smallOrders;
@property (strong, nonatomic) NSIndexPath *itsIndexPath;        //cell的唯一标识

@property BOOL canBeSelected;
@end
