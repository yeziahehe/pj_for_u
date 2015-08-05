//
//  ProductDetailViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductSubView.h"
#import "ProImageView.h"
#import "ProInfoView.h"
#import "ProCommentView.h"
#import "ProductionInfo.h"

@interface ProductDetailViewController ()
@property(strong,nonatomic)ProductionInfo *proInfo;
@property(strong,nonatomic)NSArray *productInfoArray;
@end

@implementation ProductDetailViewController

#pragma mark - Private Methods
- (void)loadDataWithfoodId:(NSString *)foodId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetFoodByIdUrl];
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:foodId forKey:@"foodId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSDictionary *valueDict = [responseObject objectForKey:@"food"];
        self.proInfo = [[ProductionInfo alloc]initWithDict:valueDict];
        [self loadSubViews];
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

-(void)loadSubViews{
    for (UIView *subView in self.contentScrollView.subviews)
    {
        if ([subView isKindOfClass:[ProductSubView class]]) {
            [subView removeFromSuperview];
        }
    }
    ProImageView *piv = [[[NSBundle mainBundle] loadNibNamed:@"ProImageView" owner:self options:nil]lastObject];
    CGRect rect = piv.frame;
    rect.origin.y = 64.f;
    piv.frame = rect;
    if (!self.proInfo) {
        piv.foodId = self.foodId;
    }
    piv.imageUrl = self.proInfo.imgUrl;
    piv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:piv];

    ProInfoView *pinv = [[[NSBundle mainBundle]loadNibNamed:@"ProInfoView" owner:self options:nil]lastObject];
    rect = pinv.frame;
    rect.origin.y = 76.f + piv.frame.size.height ;
    pinv.frame = rect;
    [self.contentScrollView addSubview:pinv];
    
    ProCommentView *pcv = [[[NSBundle mainBundle]loadNibNamed:@"ProCommentView" owner:self options:nil]lastObject];
    rect = pcv.frame;
    rect.origin.y = 88.f + piv.frame.size.height + pinv.frame.size.height;
    pcv.frame = rect;
    pcv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:pcv];
    
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, pcv.frame.origin.y + pcv.frame.size.height)];
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNaviTitle:@"商品详情"];
    [self loadDataWithfoodId:self.foodId];
}

@end
