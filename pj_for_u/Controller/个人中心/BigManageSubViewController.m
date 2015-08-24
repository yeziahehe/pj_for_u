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

@interface BigManageSubViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *cellArray;

@end

@implementation BigManageSubViewController


- (void)requestForDeliverAdmin
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kGetDeliverAdminUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:kCampusId forKey:@"campusId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetDeliverAdminKey];
}


#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigManageSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BigManageSubTableViewCell"
                                                                   forIndexPath:indexPath];
    
    NSDictionary *dict = self.cellArray[indexPath.row];
    
    cell.nickname.text = [NSString stringWithFormat:@"昵称:%@", [dict objectForKey:@"nickname"]];
    cell.phone.text = [NSString stringWithFormat:@"手机:%@", [dict objectForKey:@"phone"]];
    
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
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
