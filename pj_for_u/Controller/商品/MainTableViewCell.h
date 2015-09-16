//
//  MainTableViewCell.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductionInfo.h"

@interface MainTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet YFAsynImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *proNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *introLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *discountImageView;
@property (strong, nonatomic) ProductionInfo *pi;

@property (weak, nonatomic) IBOutlet UIImageView *cutImageView;
@property (strong, nonatomic) IBOutlet UILabel *preferential;

@end
