//
//  MainTableViewCell.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (void)awakeFromNib {
  
}

-(void)setPi:(ProductionInfo *)pi{
    _pi = pi;
    
    if ( [self.pi.isDiscount isEqualToString:@"1"]) {
        self.oldPriceLabel.hidden = NO;
        self.discountImageView.hidden = NO;
        self.priceLabel.text = [NSString stringWithFormat:@"%.1lf元",[pi.discountPrice doubleValue]];

        self.oldPriceLabel.text = [NSString stringWithFormat:@"%@元",pi.price];
    } else {
        self.oldPriceLabel.hidden = YES;
        self.discountImageView.hidden = YES;
        self.priceLabel.text = [NSString stringWithFormat:@"%.1lf元",[pi.price doubleValue]];

    }
    self.introLabel.text = pi.message;
    self.proNameLabel.text = pi.name;
    self.amountLabel.text = [NSString stringWithFormat:@"销量：%@",pi.saleNumber];
    self.image.cacheDir = kUserIconCacheDir;
    [self.image aysnLoadImageWithUrl:pi.imgUrl placeHolder:@"icon_user_default.png"];
}

@end
