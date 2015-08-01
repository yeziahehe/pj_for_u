//
//  ShoppingCarViewController.m
//  HDemo
//
//  Created by 缪宇青 on 15/8/1.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import "ShoppingCarViewController.h"
#import "ShoppingCarTableViewCell.h"

#define kGetShoppingCarDownloaderKey    @"GetShoppingCarDownloaderKey"
@interface ShoppingCarViewController ()
@property (strong, nonatomic) IBOutlet UITableView *ShoppingCarTableView;
@property (strong, nonatomic) IBOutlet UIView *settleView;
@property (strong, nonatomic) NSMutableArray *shoppingCarInfo;

@end
@implementation ShoppingCarViewController

- (void)refreshSetting
{
    self.ShoppingCarTableView.tableFooterView = self.settleView;
    [self.ShoppingCarTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.ShoppingCarTableView.delegate = self;
    self.ShoppingCarTableView.dataSource = self;
    //[self refreshSetting];
    [self requestForShoppingCar:@"18896554880" page:@"1" limit:@"3"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSoure methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shoppingCarInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"ShoppingCarTableViewCell";
    ShoppingCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ShoppingCarTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
    NSInteger row = [indexPath row];
    NSDictionary *shop = self.shoppingCarInfo[row];
    if (shop) {
        cell.mainLabel.text = [shop objectForKey:@"name"];
        NSString *imageUrl = [shop objectForKey:@"imageUrl"];
        cell.YFImageView.cacheDir = kUserIconCacheDir;
        [cell.YFImageView aysnLoadImageWithUrl:imageUrl placeHolder:@"icon_user_default.png"];
        cell.discountPrice.text = [NSString stringWithFormat:@"%@",[shop objectForKey:@"discountPrice"] ];
        cell.originPrice.text = [NSString stringWithFormat:@"原价:%@",[shop objectForKey:@"price"] ];
        cell.orderCount.text = [NSString stringWithFormat:@"%@",[shop objectForKey:@"orderCount"] ];
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)requestForShoppingCar:(NSString *)phone
                         page:(NSString *)page
                        limit:(NSString *)limit
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:page forKey:@"page"];
    [dict setObject:limit forKey:@"limit"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetShoppingCarDownloaderKey];

}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetShoppingCarDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            //[[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.shoppingCarInfo = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            for (NSDictionary *valueDict in valueArray) {

                [self.shoppingCarInfo addObject:valueDict];
            }
            [self.ShoppingCarTableView reloadData];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取图片失败";
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
