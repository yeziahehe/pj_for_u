//
//  AddressDataManager.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/30.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AddressDataManager.h"

@implementation AddressDataManager

#pragma mark - Public Methods
//请求用户的收货地址
- (void)requestForAddressWithPhoneId:(NSString *)phoneId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetAddressDownloadKey];
}

//删除某条rank收货地址请求
- (void)requestToDeleteReciverAddressWithPhoneId:(NSString *)phoneId
                                            rank:(NSString *)rank
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    if (nil == rank) {
        rank = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kDeleteReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:rank forKey:@"rank"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kDeleteAddressDownloadKey];
}

//修改收货地址请求
- (void)requestForChangeAddressWithPhoneId:(NSString *)phoneId
                                      rank:(NSString *)rank
                                      name:(NSString *)name
                                   address:(NSString *)address
                                     phone:(NSString *)phone
                                  campusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kChangeReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:rank forKey:@"rank"];
    [dict setObject:name forKey:@"name"];
    [dict setObject:address forKey:@"address"];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kChangeAddressDownloadKey];
}

//新增收货地址请求
- (void)requestToAddReciverWithPhoneId:(NSString *)phoneId
                                  name:(NSString *)name
                                 phone:(NSString *)phone
                               address:(NSString *)address
                              campusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kAddNewReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:name forKey:@"name"];
    [dict setObject:address forKey:@"address"];
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kAddReciverDownloadKey];
}

//设置默认地址
- (void)requestToSetDefaultAddressWithPhontId:(NSString *)phoneId
                                         rank:(NSString *)rank
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == phoneId) {
        phoneId = @"";
    }
    if (nil == rank) {
        rank = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kSetDefaultAddressUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:rank forKey:@"rank"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSetDefaultDownloadKey];
}

#pragma mark - Singleton methods
+ (AddressDataManager *)sharedManager
{
    static AddressDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AddressDataManager alloc] init];
    });
    return manager;
}

- (void)dealloc
{
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    //请求用户收货地址信息回调
    if ([downloader.purpose isEqualToString:kGetAddressDownloadKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];


            NSArray *valueArray = [dict objectForKey:@"receivers"];
            [[NSNotificationCenter defaultCenter]postNotificationName:kGetAddressNotification object:valueArray];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取地址失败,请稍后再试";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    
    //请求删除收货地址
    if ([downloader.purpose isEqualToString:kDeleteAddressDownloadKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            //删除收货地址数组
            [[NSNotificationCenter defaultCenter]postNotificationName:kDeleteAddressNotification object:nil];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取地址失败,请稍后再试";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    
    //修改地址请求回调
    if ([downloader.purpose isEqualToString:kChangeAddressDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [[NSNotificationCenter defaultCenter]postNotificationName:kSaveAddressNotification object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshReciverInfoNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"地址保存失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }
    //新建收货地址请求回调
    if ([downloader.purpose isEqualToString:kAddReciverDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [[NSNotificationCenter defaultCenter]postNotificationName:kAddAddressNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"新增地址失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }
    //设置默认地址请求回调
    if ([downloader.purpose isEqualToString:kSetDefaultDownloadKey])      //标记是哪个接口
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            [[YFProgressHUD sharedProgressHUD]showWithMessage:@"设置默认收货地址成功" customView:nil hideDelay:2.f];
            [[NSNotificationCenter defaultCenter]postNotificationName:kSetDefaultAddressNotification object:nil];
        }
        else        //失败
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
            {
                message = @"设置默认地址地址失败";
                [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
            }
        }
    }

    
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
