//
//  ShoppingDetailView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ChooseCategoryView.h"
#import "ShoppingCar.h"

@interface ChooseCategoryView ()
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UIView *amountView;
@property (strong, nonatomic) IBOutlet UILabel *discountPrice;
@property (strong, nonatomic) IBOutlet UILabel *oldPrice;
@property (strong, nonatomic) IBOutlet UILabel *midPrice;
@property (strong, nonatomic) ShoppingCar *shoppingCar;
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

#pragma mark - AFNetWork Methods
-(void)addShoppingCarBuyNowWithfoodId:(NSString *)foodId
                            foodCount:(NSString *)foodCount
                                 type:(NSString *)type
{
    [[YFProgressHUD sharedProgressHUD]startedNetWorkActivityWithText:@"加载中"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url;
    if ([type isEqualToString:@"1"]) {
        url = [NSString stringWithFormat:@"%@%@",kServerAddress,kAddToShoppingCarUrl];
    }
    else{
        url = [NSString stringWithFormat:@"%@%@",kServerAddress,kBuyNowUrl];
    }
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:foodCount forKey:@"foodCount"];
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        if ([type isEqualToString:@"1"]) {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"加入购物车成功" hideDelay:2.f];
            [self sendAddCarNotification];
        }
        else{
            NSDictionary *valueDict = [responseObject objectForKey:@"order"];
            self.shoppingCar = [[ShoppingCar alloc]initWithDict:valueDict];
            [self sendBuyNowNotification];
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

- (void)removeSubViews
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kRemoveChooseCategoryViewNotification object:nil];
}

//加入购物车成功发送通知
-(void)sendAddCarNotification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kSuccessAddingToCarNotification object:nil];
}
//立即购买进入确认订单详情成功
-(void)sendBuyNowNotification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kSuccessBuyNowNotification object:self.shoppingCar];
}
#pragma mark - UIView Methods
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self loadFrameWork];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(removeSubViews)];
    singleTap.numberOfTapsRequired = 1;
    [self.smallBackground addGestureRecognizer:singleTap];

}

-(void)dealloc
{
    [[YFProgressHUD sharedProgressHUD]stoppedNetWorkActivity];
}
#pragma mark - IBAction Methods
// -
- (IBAction)reduceNumber:(id)sender
{
    if (self.buyNumber == 1) {
        self.buyNumber = 1;
    }
    else{
        self.buyNumber --;
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
}

// +
- (IBAction)addNuber:(id)sender
{
    self.buyNumber ++;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
}

//加入购物车
- (IBAction)addToShoppingCar:(id)sender
{
    NSString *foodCount = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
    [self addShoppingCarBuyNowWithfoodId:self.proInfo.foodId foodCount:foodCount type:@"1"];
}

//立即购买
- (IBAction)buyNow:(id)sender
{
    NSString *foodCount = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
    [self addShoppingCarBuyNowWithfoodId:self.proInfo.foodId foodCount:foodCount type:@"2"];
}
//商品详情完成按钮
- (IBAction)doneButton:(id)sender
{
    NSString *foodCount = [NSString stringWithFormat:@"%ld",(long)self.buyNumber];
    if ([self.flag isEqualToString:@"1"]) {
        //加入购物车
        [self addShoppingCarBuyNowWithfoodId:self.proInfo.foodId foodCount:foodCount type:@"1"];
    }else{
        //立即购买
        [self addShoppingCarBuyNowWithfoodId:self.proInfo.foodId foodCount:foodCount type:@"2"];
    }
}
#pragma mark - Set Methods
-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
    self.productImage.cacheDir = kUserIconCacheDir;
    [self.productImage aysnLoadImageWithUrl:proInfo.imgUrl placeHolder:@"icon_user_default.png"];
    self.discountPrice.text = [NSString stringWithFormat:@"%.1f元",[proInfo.discountPrice doubleValue]];
    self.oldPrice.text = proInfo.price;
    CGFloat discountPrice = [proInfo.price doubleValue] - [proInfo.discountPrice doubleValue];
    self.midPrice.text = [NSString stringWithFormat:@"( 省%.1f元 )",discountPrice];
}
@end
