//
//  MyOrderTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *togetherDate;
@property (strong, nonatomic) IBOutlet UILabel *orderType;
@property (strong, nonatomic) IBOutlet YFAsynImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *orderConut;
@property (strong, nonatomic) IBOutlet UILabel *totalConut;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;

@end
