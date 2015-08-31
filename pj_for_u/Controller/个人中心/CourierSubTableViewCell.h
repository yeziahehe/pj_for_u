//
//  CourierSubTableViewCell.h
//  pj_for_u
//
//  Created by MiY on 15/8/25.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourierSubTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *orderCount;
@property (strong, nonatomic) IBOutlet UILabel *foodName;
@property (strong, nonatomic) IBOutlet UILabel *specialName;

@end
