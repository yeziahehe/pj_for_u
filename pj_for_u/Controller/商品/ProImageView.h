//
//  ProImageView.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductSubView.h"
#import "ProductionInfo.h"

@interface ProImageView : ProductSubView
@property (strong, nonatomic) IBOutlet YFAsynImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gradeLabel;
@property (strong, nonatomic) IBOutlet UILabel *saleNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong,nonatomic)ProductionInfo *proInfo;
@property(strong,nonatomic)NSString *imageUrl;
@end
