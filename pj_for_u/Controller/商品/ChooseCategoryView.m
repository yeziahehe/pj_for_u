//
//  ShoppingDetailView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ChooseCategoryView.h"

@interface ChooseCategoryView ()
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UIView *amountView;
@property (strong, nonatomic) IBOutlet UILabel *discountPrice;
@property (strong, nonatomic) IBOutlet UILabel *oldPrice;
@property (strong, nonatomic) IBOutlet UILabel *midPrice;
@property NSInteger buyNumber;
@end

@implementation ChooseCategoryView
#pragma mark - Private Methods
-(void)loadFrameWork{
    [[self.amountView layer] setCornerRadius:5];
    [[self.amountView layer] setBorderWidth:0.5];
    [[self.amountView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    CALayer * layer = [self.productImage layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.0f;
    self.buyNumber = 1;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
    
}

#pragma mark - Private Methods
-(void)addShoppingCarWithfoodId:(NSString *)foodId
                      foodCount:(NSString *)foodCount
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kAddToShoppingCarUrl];
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:foodCount forKey:@"foodCount"];
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"加入购物车成功" hideDelay:2.f];
        [self sendNotification];
        NSLog(@"加入购物车成功");
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}
- (IBAction)doneButton:(id)sender {
    if ([self.flag isEqualToString:@"1"]) {
        NSString *foodCount = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
        [self addShoppingCarWithfoodId:self.proInfo.foodId foodCount:foodCount];
    }
}
-(void)sendNotification{
    [[NSNotificationCenter defaultCenter]postNotificationName:kSuccessAddingToCarNotification object:nil];

}
#pragma mark - UIView Methods
-(void)awakeFromNib{
    [super awakeFromNib];
    [self loadFrameWork];
    
}

#pragma mark - IBAction Methods
// -
- (IBAction)reduceNumber:(id)sender {
    if (self.buyNumber == 1) {
        self.buyNumber = 1;
    }
    else{
        self.buyNumber --;
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
}

// +
- (IBAction)addNuber:(id)sender {
    self.buyNumber ++;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
}

//加入购物车
- (IBAction)addToShoppingCar:(id)sender {
    NSString *foodCount = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
    [self addShoppingCarWithfoodId:self.proInfo.foodId foodCount:foodCount];
}

//立即购买
- (IBAction)buyNow:(id)sender {
    
}

#pragma mark - Set Methods
-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    self.productImage.cacheDir = kUserIconCacheDir;
    [self.productImage aysnLoadImageWithUrl:proInfo.imgUrl placeHolder:@"icon_user_default.png"];
    self.discountPrice.text = [NSString stringWithFormat:@"%@元",proInfo.discountPrice];
    self.oldPrice.text = proInfo.price;
    CGFloat discountPrice = [proInfo.price doubleValue] - [proInfo.discountPrice doubleValue];
    self.midPrice.text = [NSString stringWithFormat:@"( 省%.1f元 )",discountPrice];
}
@end
