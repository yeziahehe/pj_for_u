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
#import "ShoppingCarViewController.h"
#import "ConfirmOrderViewController.h"
#import "LoginViewController.h"

@interface ProductDetailViewController ()
@property(strong,nonatomic)ProductionInfo *proInfo;
@property (nonatomic, strong) NSMutableArray *subViewArray;
@property(strong,nonatomic)NSArray *productInfoArray;
@property(strong,nonatomic)NSString *isLoaded;
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
    NSLog(@"移除subview成功");
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
    self.subViewArray = [NSMutableArray arrayWithObjects:@"ProImageView", @"ProInfoView", @"ProCommentView",nil];
    
    //加载每个子模块
    CGFloat originY = 0.f;
    [self.contentScrollView layoutIfNeeded];
    for (NSString *classString in self.subViewArray) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:classString owner:self options:nil];
        ProductSubView *productSubView = [nibs lastObject];
        CGRect rect = productSubView.frame;
        rect.size.width = ScreenWidth;
        rect.origin.y = originY;
        rect.origin.x = 0;
        if ([productSubView isKindOfClass:[ProImageView class]]) {
            ProImageView *proImageView = (ProImageView *)productSubView;
            proImageView.imageUrl = self.proInfo.imgUrl;
            proImageView.proInfo = self.proInfo;
            rect.size.width = ScreenWidth;
            rect.size.height = ScreenWidth + 101.f;
            rect.origin.y += 64.f;
        }
        else if ([productSubView isKindOfClass:[ProInfoView class]]) {
            ProInfoView *proInfoView = (ProInfoView *)productSubView;
            proInfoView.proInfo = self.proInfo;
            rect.size.height = 44.f;
            rect.origin.y += 10.f;
        }
        else if ([productSubView isKindOfClass:[ProCommentView class]]){
            ProCommentView *proCommentView = (ProCommentView *)productSubView;
            rect.origin.y += 10.f;
            proCommentView.proInfo = self.proInfo;
            rect.size.height = proCommentView.tableView.contentSize.height;
        }
        productSubView.frame = rect;
        [self.contentScrollView addSubview:productSubView];
        originY = rect.origin.y + rect.size.height;
    }
    self.isLoaded = @"1";
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, originY + 44.f)];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

-(void)heightForTableViewWithNotification:(NSNotification *)notification{
    CGFloat height = [notification.object doubleValue];
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, self.contentScrollView.contentSize.height + height)];
}

-(void)buyNowWithNotification:(NSNotification *)notification{
    [self removeSubViews];
    NSMutableArray *OrderArray = [[NSMutableArray alloc]initWithObjects:notification.object, nil];
    ConfirmOrderViewController *covc = [[ConfirmOrderViewController alloc]initWithNibName:@"ConfirmOrderViewController" bundle:nil];
    covc.selectedArray = OrderArray;
    covc.buyNowFlag = @"1";
    [self.navigationController pushViewController:covc animated:YES];
}

- (void)removeChooseCategoryViewNotification
{
    [self removeSubViews];
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNaviTitle:@"商品详情"];
    [self setRightNaviItemWithTitle:nil imageName:@"icon_shopcarright"];
    [self loadDataWithfoodId:self.foodId];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSubViews) name:kSuccessAddingToCarNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buyNowWithNotification:) name:kSuccessBuyNowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(heightForTableViewWithNotification:) name:kHeightForTBVNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeChooseCategoryViewNotification) name:kRemoveChooseCategoryViewNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![self.isLoaded isEqualToString:@"1"]) {
        [[YFProgressHUD sharedProgressHUD]startedNetWorkActivityWithText:@"加载中"];
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - IBAction Methods
- (IBAction)addShoppingCarAndBuyNow:(UIButton *)sender {
    if (![MemberDataManager sharedManager].loginMember.phone) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }else{
    self.chooseCategoryView = [[[NSBundle mainBundle]loadNibNamed:@"ChooseCategoryView" owner:self options:nil]lastObject];
    //传递参数
    self.chooseCategoryView.proInfo = self.proInfo;
    if (sender.tag == 1) {
        self.chooseCategoryView.flag = @"1";
    }
    else{
        self.chooseCategoryView.flag = @"2";
    }
    CGFloat height = self.chooseCategoryView.frame.size.height;
    [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
    [self.view addSubview:self.background];
    [self.view addSubview:self.chooseCategoryView];
    [UIView animateWithDuration:0.2 animations:^{
        [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, height)];
    }];
    }
}


-(void)rightItemTapped{
    self.tabBarController.selectedIndex = 1;
    [self.navigationController popToRootViewControllerAnimated:NO];
}
@end
