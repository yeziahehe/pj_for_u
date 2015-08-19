//
//  ProImageView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProImageView.h"

@interface ProImageView ()

@property (strong, nonatomic) IBOutlet YFAsynImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;
@property (strong, nonatomic) IBOutlet UILabel *saleNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage;
@property (strong, nonatomic) IBOutlet UIImageView *cutImageView;

@end

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
    _foodId = foodId;
}

-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    self.nameLabel.text = proInfo.name;
    self.messageLabel.text = proInfo.message;
    self.saleNumLabel.text = [NSString stringWithFormat:@"销量：%@",proInfo.saleNumber];
    CGFloat discountPrice = [proInfo.price doubleValue] - [proInfo.discountPrice doubleValue];
    
    if ([proInfo.isDiscount isEqualToString:@"1"]) {
        self.oldPriceLabel.hidden = NO;
        self.discountLabel.hidden = NO;
        self.lineImage.hidden = NO;
        self.cutImageView.hidden = NO;
        
        self.priceLabel.text = [NSString stringWithFormat:@"￥: %.1f",[proInfo.discountPrice doubleValue]];
        self.discountLabel.text = [NSString stringWithFormat:@"( 省%.1f元 )",discountPrice];
        self.oldPriceLabel.text = [NSString stringWithFormat:@"%@",proInfo.price];

    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"￥: %.1f",[proInfo.price doubleValue]];
        
        self.lineImage.hidden = YES;
        self.oldPriceLabel.hidden = YES;
        self.discountLabel.hidden = YES;
        self.cutImageView.hidden = YES;
    }
    
    if (!proInfo.grade) {
        self.gradeLabel.text = proInfo.grade;
    }
}
@end
