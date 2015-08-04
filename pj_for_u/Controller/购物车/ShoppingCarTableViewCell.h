//
//  ShoppingCarTableViewCell.h
//  HDemo
//
//  Created by 缪宇青 on 15/8/1.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCarTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet YFAsynImageView *YFImageView;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountPrice;
@property (strong, nonatomic) IBOutlet UILabel *originPrice;
@property (strong, nonatomic) IBOutlet UILabel *orderCount;
@property (strong, nonatomic) IBOutlet UIButton *PlusButton;
@property (strong, nonatomic) IBOutlet UIButton *MinusButton;
@property int amount;
@property (strong, nonatomic) NSIndexPath *shoppingId;

@end
