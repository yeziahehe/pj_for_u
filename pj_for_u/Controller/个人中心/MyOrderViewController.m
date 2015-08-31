//
//  MyOrderViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderTableViewCell.h"
#import "MyOrderDetailViewController.h"
#import "MyOrderEvaluationViewController.h"
#import "ShoppingCar.h"
#import "ConfirmOrderViewController.h"

#define sizeofPage                  @"30"
#define sizeofPageInt               30

#define kGetOrderInMineKey          @"GetOrderInMineKey"
#define kDeleteOrderKey             @"DeleteOrderKey"
#define kSetOrderInvalidKey         @"SetOrderInvalidKey"
#define kModifyOrderStatusKey       @"ModifyOrderStatusKey"

@interface MyOrderViewController ()

@property (strong, nonatomic) IBOutlet UIButton *waitForPayment;
@property (strong, nonatomic) IBOutlet UIButton *waitForConfirm;
@property (strong, nonatomic) IBOutlet UIButton *distributing;
@property (strong, nonatomic) IBOutlet UIButton *waitForEvaluation;
@property (strong, nonatomic) IBOutlet UIButton *alreadyFinished;

@property (strong, nonatomic) IBOutlet UIView *waitForPaymentView;
@property (strong, nonatomic) IBOutlet UIView *waitForConfirmView;
@property (strong, nonatomic) IBOutlet UIView *distributingView;
@property (strong, nonatomic) IBOutlet UIView *waitForEvaluationView;
@property (strong, nonatomic) IBOutlet UIView *alreadyFinishedView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *orderListArray;       //大订单信息
@property (strong, nonatomic) NSMutableArray *eachCountOfSmallOrders;       //保存每个大订单中小订单的个数

@property (strong, nonatomic) IBOutlet UIView *noOrderView;     //随便逛逛view
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;

@property int recordLastStatus;     //保存当前显示在屏幕上的的订单状态

@property (strong, nonatomic) NSString *lastestId;
@property BOOL isRefreshHeader;
@property int indexOfPage;

@property NSInteger indexPathBuffer;

@property (strong, nonatomic) NSString *orderCampusId;
@property (strong, nonatomic) NSArray *preferentials;
@property (strong, nonatomic) NSDictionary *homeInfo;
@property (strong, nonatomic) NSMutableArray *shoppingCar;

@end

@implementation MyOrderViewController

#pragma mark NetWork Methods
- (void)getHomeCateGoryInfoWithCampusId:(NSString *)campusId
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetModuleTypeUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetModuleTypeUrl];
    
}


- (void)getPreferentialsInfoWithCampusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetPreferentialsUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetPreferentialsUrl];
    
}

//请求修改订单状态
- (void)requsetForModifyOrderStatus:(NSString *)status togetherId:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kModifyOrderStatusUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    if (status && togetherId) {
        [dict setObject:status forKey:@"status"];
        [dict setObject:togetherId forKey:@"togetherId"];
    }
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kModifyOrderStatusKey];
}

//请求我的订单信息，通过不同状态
- (void)requestForMyOrderByStatus:(NSString *)status page:(NSString *)page limit:(NSString *)limit
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kGetOrderInMine];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phoneId"];
    if (status) {
        [dict setObject:status forKey:@"status"];
    }
    if (page && limit) {
        [dict setObject:page forKey:@"page"];
        [dict setObject:limit forKey:@"limit"];
    }
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetOrderInMineKey];
}

//请求删除订单
- (void)requestForDeleteOrder:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kDeleteOrderUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:togetherId forKey:@"togetherId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kDeleteOrderKey];
}

//请求取消订单
- (void)requestForSetOrderInvalid:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSetOrderInvalidUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:togetherId forKey:@"togetherId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSetOrderInvalidKey];
}

#pragma mark - Private Methods
//改变cell按钮的类型
- (void)changeButtonTypeByStatus:(NSString *)status forTableViewCell:(MyOrderTableViewCell *)cell
{
    //通过status判断是什么状态，由此来确定每个按钮下应该显示的界面
    cell.rightButton.hidden = NO;
    cell.leftButton.hidden = NO;
    if ([status isEqualToString:@"1"]) {
        CALayer *layer = [cell.leftButton layer];
        layer.borderColor = [[UIColor redColor] CGColor];
        [cell.leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cell.leftButton setTitle:@"立即付款" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"取消订单" forState:UIControlStateNormal];
    }
    if ([status isEqualToString:@"2"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"取消订单" forState:UIControlStateNormal];
        //markkkkkkkkkk
        if ([[MemberDataManager sharedManager].loginMember.type isEqualToString:@"1"]) {
            [cell.rightButton setTitle:@"确认配送" forState:UIControlStateNormal];
        }
    }
    if ([status isEqualToString:@"3"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"确认收货" forState:UIControlStateNormal];;
    }
    if ([status isEqualToString:@"4"]) {
        CALayer *layer = [cell.leftButton layer];
        layer.borderColor = [[UIColor darkGrayColor] CGColor];
        [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [cell.leftButton setTitle:@"删除订单" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"评价订单" forState:UIControlStateNormal];;
    }
    if ([status isEqualToString:@"5"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];;
    }
}

//上拉加载，要传递value array的个数
- (void)loadInfoByRefreshFooterWithValueCount:(NSInteger)count
{
    //====================上拉加载==================
    UIView *postInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 34)];
    UILabel *postInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, ScreenWidth, 20)];
    postInfoLabel.textAlignment = NSTextAlignmentCenter;
    postInfoLabel.font = [UIFont systemFontOfSize:12.0];
    postInfoLabel.textColor = [UIColor darkGrayColor];
    [postInfoView addSubview:postInfoLabel];
    
    
    if (self.orderListArray.count == 0) {
        self.tableView.footerHidden = YES;
        self.tableView.hidden = YES;
        CGRect frame = self.noOrderView.frame;
        frame.origin.x = 0;
        frame.origin.y = 94;
        frame.size.width = ScreenWidth;
        frame.size.height = ScreenHeight - 94;
        self.noOrderView.frame = frame;
        [self.view addSubview:self.noOrderView];
        
    } else {
        self.tableView.hidden = NO;
        [self.noOrderView removeFromSuperview];
        if (count < sizeofPageInt) {
            self.tableView.footerHidden = YES;
        }
        self.lastestId = [NSString stringWithFormat:@"%d", ++self.indexOfPage];
        
        [self.tableView reloadData];
        
    }
    self.tableView.tableFooterView = postInfoView;
    //==============================================
    self.isRefreshHeader = NO;

}

//显示随便逛逛，包含判断是否要显示
- (void)showNoOrderView
{
    //如果没数据就显示随便逛逛页面
    if (self.orderListArray.count == 0) {
        self.tableView.hidden = YES;
        CGRect frame = self.noOrderView.frame;
        frame.origin.x = 0;
        frame.origin.y = 94;
        frame.size.width = ScreenWidth;
        frame.size.height = ScreenHeight - 94;
        self.noOrderView.frame = frame;
        [self.view addSubview:self.noOrderView];
    } else {
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        [self.noOrderView removeFromSuperview];
    }

}

//重置角标
- (void)resetBadgeNum
{
    NSString *badgeNum = [NSString stringWithFormat:@"%lu", (unsigned long)self.orderListArray.count];
    switch (self.recordLastStatus) {
        case 1:
            for (UIView *subView in self.waitForPayment.subviews) {
                if ([subView isKindOfClass:[YFBadgeView class]]) {
                    [subView removeFromSuperview];
                }
            }
            
            [self setBadgeViewWithView:self.waitForPayment badgeNum:badgeNum];
            break;
            
        case 2:
            for (UIView *subView in self.waitForConfirm.subviews) {
                if ([subView isKindOfClass:[YFBadgeView class]]) {
                    [subView removeFromSuperview];
                }
            }
            
            [self setBadgeViewWithView:self.waitForConfirm badgeNum:badgeNum];
            break;
        case 3:
            for (UIView *subView in self.distributing.subviews) {
                if ([subView isKindOfClass:[YFBadgeView class]]) {
                    [subView removeFromSuperview];
                }
            }
            
            [self setBadgeViewWithView:self.distributing badgeNum:badgeNum];
            break;
            
        case 4:
            for (UIView *subView in self.waitForEvaluation.subviews) {
                if ([subView isKindOfClass:[YFBadgeView class]]) {
                    [subView removeFromSuperview];
                }
            }
            
            [self setBadgeViewWithView:self.waitForEvaluation badgeNum:badgeNum];
            break;
        case 5:
            for (UIView *subView in self.alreadyFinished.subviews) {
                if ([subView isKindOfClass:[YFBadgeView class]]) {
                    [subView removeFromSuperview];
                }
            }
            
            [self setBadgeViewWithView:self.alreadyFinished badgeNum:badgeNum];
            break;
        default:
            break;
    }

}

//上拉加载
- (void)refreshFooter
{
    NSString *more = @"1";
    if (self.orderListArray.count != 0) {
        more = self.lastestId;
    }
    [self requestForMyOrderByStatus:[NSString stringWithFormat:@"%d", self.recordLastStatus] page:more limit:sizeofPage];
    
}

//下拉刷新
- (void)refreshHeader
{
    self.isRefreshHeader = YES;
    self.indexOfPage = 1;
    self.lastestId = @"1";
    [self requestForMyOrderByStatus:[NSString stringWithFormat:@"%d", self.recordLastStatus] page:@"1" limit:sizeofPage];
}


//设置角标
- (void)setBadgeViewWithView:(UIView *)parentView badgeNum:(NSString *)badgeNum
{

    if (![badgeNum isEqualToString:@"0"]) {
        YFBadgeView *badgeView = [[YFBadgeView alloc]initWithParentView:parentView alignment:YFBadgeViewAlignmentTopRight];
        badgeView.badgeBackgroundColor = [UIColor redColor];
        badgeView.badgeTextFont = [UIFont boldSystemFontOfSize:11];
        badgeView.badgeText = badgeNum;
    }
}

//为五个按钮添加角标
- (void)addBadgeViewToButton
{
    //角标
    [self setBadgeViewWithView:self.waitForPayment badgeNum:[MemberDataManager sharedManager].mineInfo.waitPayOrder];
    [self setBadgeViewWithView:self.waitForConfirm badgeNum:[MemberDataManager sharedManager].mineInfo.waitMakeSureOrder];
    [self setBadgeViewWithView:self.distributing badgeNum:[MemberDataManager sharedManager].mineInfo.distribution];
    [self setBadgeViewWithView:self.waitForEvaluation badgeNum:[MemberDataManager sharedManager].mineInfo.waitCommentOrder];
    [self setBadgeViewWithView:self.alreadyFinished badgeNum:[MemberDataManager sharedManager].mineInfo.doneOrder];

    
}



#pragma mark - Universal AND IBAciton
//==================随便逛逛================
- (IBAction)goAround
{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}

//==================将按钮边框和底下条纹设置成默认===========
- (void)changeButtonToBlackColor
{
    [self.waitForPayment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForPaymentView.backgroundColor = [UIColor clearColor];
    
    [self.waitForConfirm setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForConfirmView.backgroundColor = [UIColor clearColor];
    
    [self.waitForEvaluation setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForEvaluationView.backgroundColor = [UIColor clearColor];
    
    [self.distributing setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.distributingView.backgroundColor = [UIColor clearColor];
    
    [self.alreadyFinished setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.alreadyFinishedView.backgroundColor = [UIColor clearColor];
}

//==============以下点击事件将待付款一栏和底下条纹颜色变为红色并调用网络请求================
- (void)waitForPaymentAction
{
    [self changeButtonToBlackColor];
    [self.waitForPayment setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForPaymentView.backgroundColor = [UIColor redColor];
    self.recordLastStatus = 1;
    [self refreshHeader];

}

- (void)waitForConfirmAction
{
    [self changeButtonToBlackColor];
    [self.waitForConfirm setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForConfirmView.backgroundColor = [UIColor redColor];
    self.recordLastStatus = 2;
    [self refreshHeader];
}

- (void)distributingAction
{
    [self changeButtonToBlackColor];
    
    [self.distributing setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.distributingView.backgroundColor = [UIColor redColor];
    self.recordLastStatus = 3;
    [self refreshHeader];
}

- (void)waitForEvaluationAction
{
    [self changeButtonToBlackColor];
    [self.waitForEvaluation setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForEvaluationView.backgroundColor = [UIColor redColor];
    self.recordLastStatus = 4;
    [self refreshHeader];

}

- (void)alreadyFinishedAction
{
    [self changeButtonToBlackColor];
    [self.alreadyFinished setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.alreadyFinishedView.backgroundColor = [UIColor redColor];
    self.recordLastStatus = 5;
    [self refreshHeader];

}

//=========给待收货一栏按钮添加点击事件=========
- (void)addTargetToButton
{
    [self.waitForPayment addTarget:self action:@selector(waitForPaymentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForConfirm addTarget:self action:@selector(waitForConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.distributing addTarget:self action:@selector(distributingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForEvaluation addTarget:self action:@selector(waitForEvaluationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.alreadyFinished addTarget:self action:@selector(alreadyFinishedAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Initialize

- (NSMutableArray *)shoppingCar
{
    if (!_shoppingCar) {
        _shoppingCar = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _shoppingCar;
}

- (NSMutableArray *)orderListArray
{
    if (!_orderListArray) {
        _orderListArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return  _orderListArray;
}

- (NSMutableArray *)eachCountOfSmallOrders
{
    if (!_eachCountOfSmallOrders) {
        _eachCountOfSmallOrders = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _eachCountOfSmallOrders;
}


#pragma mark - Notification Methods
//=============订单详情===========
- (void)pushToMyOrderDetailViewController:(NSNotification *)notification
{
    NSIndexPath *indexPath = (NSIndexPath *)notification.object;
    
    NSDictionary *orderList = self.orderListArray[indexPath.section];
    
    NSString *togetherId = [orderList objectForKey:@"togetherId"];
    
    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
    myOrderDetailViewController.togetherId = togetherId;
    
    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];

}

//============点击左或者右两个按钮发生的事件，通过title来判断============
- (void)cilckOrderButtonNotification:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
    NSArray *smallOrders = [self.orderListArray[indexPath.section] objectForKey:@"smallOrders"];
    NSString *togetherId = [self.orderListArray[indexPath.section] objectForKey:@"togetherId"];
    NSString *title = [dict objectForKey:@"title"];

    //cell各个按钮的不同功能，通过current title判断按钮类型
    if ([title isEqualToString:@"评价订单"]) {
        NSMutableArray *realSmallOrders = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *dict in smallOrders) {
            NSString *isRemarked = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isRemarked"]];
            if ([isRemarked isEqualToString:@"0"]) {
                [realSmallOrders addObject:dict];
            }
        }
        MyOrderEvaluationViewController *myOrderEvaluationViewController = [[MyOrderEvaluationViewController alloc] init];
        myOrderEvaluationViewController.smallOrders = realSmallOrders;
        
        [self.navigationController pushViewController:myOrderEvaluationViewController animated:YES];
        
    }
    
    else if ([title isEqualToString:@"删除订单"]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除订单"
                                                                       message:@"是否删除订单？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    self.indexPathBuffer = indexPath.section;
                                                    [self requestForDeleteOrder:togetherId];
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];

        
     }
    
    else if ([title isEqualToString:@"立即付款"]) {
        
        int i = 0;
        for (NSDictionary *dict in smallOrders) {
            if (i == 0) {
                self.orderCampusId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"campusId"]];
                [self getPreferentialsInfoWithCampusId:self.orderCampusId];
                i++;
            }
            ShoppingCar *car = [[ShoppingCar alloc] initWithDict:dict];
            [self.shoppingCar addObject:car];
        }
    }
    
    else if ([title isEqualToString:@"取消订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"取消订单"
                                                                       message:@"是否取消订单？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    self.indexPathBuffer = indexPath.section;
                                                    [self requestForSetOrderInvalid:togetherId];
                                                    
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    //markkkkkkkkkkk
    else if ([title isEqualToString:@"确认收货"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认收货"
                                                                       message:@"是否确认？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    self.indexPathBuffer = indexPath.section;
                                                    [self requsetForModifyOrderStatus:@"4" togetherId:togetherId];
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];

    }
    
    else if ([title isEqualToString:@"确认配送"]) {
        self.indexPathBuffer = indexPath.section;
        [self requsetForModifyOrderStatus:@"3" togetherId:togetherId];
    }
}


#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderTableViewCell"
                                                                 forIndexPath:indexPath];
    if (self.orderListArray) {
        NSDictionary *orderInfoDictionary = self.orderListArray[indexPath.section];
        NSArray *smallOrders = [orderInfoDictionary objectForKey:@"smallOrders"];
        cell.togetherDate.text = [orderInfoDictionary objectForKey:@"togetherDate"];
        cell.smallOrders = smallOrders;
        [cell.tableView reloadData];
        
        //后台不给。。。手动计算个数
        int count = 0;
        for (NSDictionary *dict in smallOrders) {
            count += [[dict objectForKey:@"orderCount"] intValue];
        }
        cell.itsIndexPath = indexPath;
        cell.totalConut.text = [NSString stringWithFormat:@"共%d件商品", count];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%@", [orderInfoDictionary objectForKey:@"totalPrice"]];
        
        NSString *status = [NSString stringWithFormat:@"%@", [orderInfoDictionary objectForKey:@"status"]];
        
        [self changeButtonTypeByStatus:status forTableViewCell:cell];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderListArray.count;
}

//计算每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.eachCountOfSmallOrders.count > indexPath.section) {
        return 108.f + [self.eachCountOfSmallOrders[indexPath.section] intValue] * 70.f;
    } else {
        return 178.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"我的订单"];
    
    self.indexOfPage = 1;
    self.isRefreshHeader = NO;
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderTableViewCell"];
    //=============
    
    [self addBadgeViewToButton];
    [self addTargetToButton];
    
    //随便逛逛按钮增加圆角边框
    CALayer *layer = [self.goAroundButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.goAroundButton.layer.masksToBounds = YES;
    self.goAroundButton.layer.cornerRadius = 2.5f;
    
    [self.tableView addHeaderWithTarget:self action:@selector(refreshHeader)];
    [self.tableView addFooterWithTarget:self action:@selector(refreshFooter)];
    
    self.recordLastStatus = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToMyOrderDetailViewController:)
                                                 name:kPushToMyOrderDetailNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cilckOrderButtonNotification:)
                                                 name:kCilckOrderButtonNotification object:nil];
    
    //每次进入页面刷新数据
    switch (self.recordLastStatus) {
        case 1:
            [self waitForPaymentAction];
            break;
        case 2:
            [self waitForConfirmAction];
            break;
        case 3:
            [self distributingAction];
            break;
        case 4:
            [self waitForEvaluationAction];
            break;
        case 5:
            [self alreadyFinishedAction];
            break;
        default:
            break;
    }
    
    self.orderCampusId = nil;
    self.preferentials = nil;
    self.homeInfo = nil;
    self.shoppingCar = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];

}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetOrderInMineKey]) {
        [self.tableView footerEndRefreshing];
        [self.tableView headerEndRefreshing];

        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            
            if (self.isRefreshHeader) {
                [self.orderListArray removeAllObjects];
                self.tableView.footerHidden = NO;
            }

            for (NSDictionary *dict in valueArray) {
                [self.orderListArray addObject:dict];
            }

            [self.eachCountOfSmallOrders removeAllObjects];
            for (NSDictionary *dict in self.orderListArray) {
                NSArray *smallOrders = [dict objectForKey:@"smallOrders"];
                NSNumber *smallOrderCount = [NSNumber numberWithInteger:smallOrders.count];
                [self.eachCountOfSmallOrders addObject:smallOrderCount];
            }
            
            //带判功能的显示随便逛逛
            [self showNoOrderView];
            
            //上拉加载
            [self loadInfoByRefreshFooterWithValueCount:valueArray.count];
            
            //重置角标
            [self resetBadgeNum];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"信息获取失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kDeleteOrderKey]) {
        NSString *message = [dict objectForKey:kMessageKey];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [self.orderListArray removeObjectAtIndex:self.indexPathBuffer];
            [self.eachCountOfSmallOrders removeObjectAtIndex:self.indexPathBuffer];
            
            [self refreshHeader];

        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"订单删除失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kSetOrderInvalidKey]) {
        NSString *message = [dict objectForKey:kMessageKey];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            
            [self.orderListArray removeObjectAtIndex:self.indexPathBuffer];
            [self.eachCountOfSmallOrders removeObjectAtIndex:self.indexPathBuffer];
            
            [self refreshHeader];
        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"取消订单失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kModifyOrderStatusKey]) {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [self.orderListArray removeObjectAtIndex:self.indexPathBuffer];
            [self.eachCountOfSmallOrders removeObjectAtIndex:self.indexPathBuffer];
            
            [self refreshHeader];
        }
        else
        {
            NSString *message = @"确认失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kGetPreferentialsUrl]) {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            self.preferentials = [dict objectForKey:@"preferential"];
            [self getHomeCateGoryInfoWithCampusId:self.orderCampusId];
            
        }
        else
        {
            NSString *message = @"获取满减信息失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kGetModuleTypeUrl]) {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            
            self.homeInfo = [dict objectForKey:@"campus"];
            
            ConfirmOrderViewController *covc = [[ConfirmOrderViewController alloc] init];
            
            covc.preferentials = self.preferentials;
            covc.homeInfo = self.homeInfo;
            covc.selectedArray = self.shoppingCar;
            covc.isBeSentFromMyOrder = 1;
            covc.myOrderCampusId = self.orderCampusId;
            
            [self.navigationController pushViewController:covc animated:YES];
        }
        else
        {
            NSString *message = @"获取营业时间失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }

}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
