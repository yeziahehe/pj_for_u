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
#import "ChooseCategoryView.h"

@interface ProductDetailViewController ()
@property(strong,nonatomic)ProductionInfo *proInfo;
@property(strong,nonatomic)NSArray *productInfoArray;
@property(strong,nonatomic)UIView *background;
@property(strong,nonatomic)ChooseCategoryView *chooseCategoryView;
@end

@implementation ProductDetailViewController
#pragma mark - 懒加载
- (UIView *)background
{
    if (!_background) {
        _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _background.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(removeSubViews)];
        singleTap.numberOfTapsRequired = 1;
        [_background addGestureRecognizer:singleTap];
    }
    return _background;
}

-(void)removeSubViews{
    CGFloat height = self.chooseCategoryView.frame.size.height;
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self.chooseCategoryView removeFromSuperview];
                             self.chooseCategoryView = nil;
                         }
                     }];
    [self.background removeFromSuperview];
}
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
        [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];

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
    piv.imageUrl = self.proInfo.imgUrl;
    piv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:piv];

    ProInfoView *pinv = [[[NSBundle mainBundle]loadNibNamed:@"ProInfoView" owner:self options:nil]lastObject];
    rect = pinv.frame;
    rect.origin.y = 76.f + piv.frame.size.height ;
    pinv.frame = rect;
    pinv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:pinv];
    
    ProCommentView *pcv = [[[NSBundle mainBundle]loadNibNamed:@"ProCommentView" owner:self options:nil]lastObject];
    rect = pcv.frame;
    rect.origin.y = 88.f + piv.frame.size.height + pinv.frame.size.height;
    pcv.frame = rect;
    pcv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:pcv];
    
    
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth,pcv.frame.origin.y + pcv.frame.size.height)];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

-(void)setContentSizeForScrollViewWithheight:(CGFloat)height
{
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth,height)];
}
#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNaviTitle:@"商品详情"];
    [self loadDataWithfoodId:self.foodId];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSubViews) name:kSuccessAddingToCarNotification object:nil];

}

- (IBAction)addShoppingCar:(id)sender {
    self.chooseCategoryView = [[[NSBundle mainBundle]loadNibNamed:@"ChooseCategoryView" owner:self options:nil]lastObject];
    //传递参数
    self.chooseCategoryView.proInfo = self.proInfo;
    self.chooseCategoryView.flag = @"1";
    CGFloat height = self.chooseCategoryView.frame.size.height;
    [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
    [self.view addSubview:self.background];
    [self.view addSubview:self.chooseCategoryView];
    [UIView animateWithDuration:0.2 animations:^{
        [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, height)];
    }];
}


@end
