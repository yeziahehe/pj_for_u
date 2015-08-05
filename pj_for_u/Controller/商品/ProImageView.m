//
//  ProImageView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProImageView.h"

@implementation ProImageView


-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    self.imageView.cacheDir = kUserIconCacheDir;
    [self.imageView aysnLoadImageWithUrl:imageUrl placeHolder:@"icon_user_default.png"];
    
}

-(void)setFoodId:(NSString *)foodId{
    
}

-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    self.nameLabel.text = proInfo.name;
    self.messageLabel.text = proInfo.message;
    self.priceLabel.text = [NSString stringWithFormat:@"￥：%@",proInfo.discountPrice];
    self.oldPriceLabel.text = [NSString stringWithFormat:@"%@",proInfo.price];
    self.saleNumLabel.text = [NSString stringWithFormat:@"销量：%@",proInfo.saleNumber];
    CGFloat discountPrice = [proInfo.price doubleValue] - [proInfo.discountPrice doubleValue];
    self.discountLabel.text = [NSString stringWithFormat:@"( 省%.1f元 )",discountPrice];
    if (!proInfo.grade) {
        self.gradeLabel.text = proInfo.grade;
    }
}
@end
