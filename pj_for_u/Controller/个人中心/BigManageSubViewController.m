//
//  BigManageSubViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BigManageSubViewController.h"
#import "BigManageSubTableViewCell.h"

#define kGetDeliverAdminKey             @"GetDeliverAdminKey"
#define kSetDeliverAdminKey             @"kSetDeliverAdminKey"

@interface BigManageSubViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *cellArray;

@end

@implementation BigManageSubViewController



- (void)setDeliverAdminWithAdminPhone:(NSString *)adminPhone
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSetDeliverAdminUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:self.togetherId forKey:@"togetherId"];
    [dict setObject:adminPhone forKey:@"adminPhone"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSetDeliverAdminKey];
}


- (void)requestForDeliverAdmin
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kGetDeliverAdminUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:kCampusId forKey:@"campusId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetDeliverAdminKey];
}

- (void)callAdminPhone:(NSNotification *)notification
{
    NSString *phone = (NSString *)notification.object;
    UIAlertController *phonealert = [UIAlertController alertControllerWithTitle:nil
                                                                        message:phone
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [phonealert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     //
                                                 }]];
    [phonealert addAction:[UIAlertAction actionWithTitle:@"拨打"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phone]];
                                                     [[UIApplication sharedApplication] openURL:telURL];
                                                 }]];
    [self presentViewController:phonealert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigManageSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BigManageSubTableViewCell"
                                                                   forIndexPath:indexPath];
    
    NSDictionary *dict = self.cellArray[indexPath.row];
    
    cell.nickname.text = [NSString stringWithFormat:@"昵称:%@", [dict objectForKey:@"nickname"]];
    cell.phone.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"phone"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61.0;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (int i = 0; i < self.cellArray.count; i++) {
        NSIndexPath *indexPathTemp = [NSIndexPath indexPathForRow:i inSection:0];
        BigManageSubTableViewCell *cell = (BigManageSubTableViewCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    BigManageSubTableViewCell *cell = (BigManageSubTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self setDeliverAdminWithAdminPhone:cell.phone.text];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNaviTitle:@"所有配送员"];
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"BigManageSubTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"BigManageSubTableViewCell"];
    //=============
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAdminPhone:) name:kCallAdminPhoneNotification object:nil];
    
    [self requestForDeliverAdmin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    
    if ([downloader.purpose isEqualToString:kGetDeliverAdminKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            
            self.cellArray = [dict objectForKey:@"deliverAdmins"];
            
            [self.tableView reloadData];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            if(message.length == 0)
                message = @"信息获取失败";
            
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kSetDeliverAdminKey])
    {
        NSString *message = [dict objectForKey:kMessageKey];

        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            if(message.length == 0)
                message = @"信息获取失败";
            
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
