//
//  ProductDataManager.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductDataManager.h"

#define kGetCategoryDownloadKey     @"GetCategoryDownloadKey"
#define kGetCategoryFoodDownloadKedy    @"kGetCategoryFoodDownloadKedy"

@implementation ProductDataManager

#pragma mark - Network Methods
//请求分类信息
- (void)requestForAddressWithCampusId:(NSString *)campusId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == campusId) {
        campusId = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:campusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetCategoryDownloadKey];
}
//请求某一分类下得
-(void)requestForProductWithCampusId:(NSString *)campusId
                          categoryId:(NSString *)categoryId
                                page:(NSString *)page
                               limit:(NSString *)limit
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    if (nil == campusId) {
        campusId = @"";
    }
    if (nil == categoryId) {
        categoryId = @"";
    }
    if (nil == page){
        page = @"";
    }
    if (nil == limit) {
        limit = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryFoodUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:campusId forKey:@"campusId"];
    [dict setObject:categoryId forKey:@"categoryId"];
    [dict setObject:page forKey:@"page"];
    [dict setObject:limit forKey:@"limit"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetCategoryFoodDownloadKedy];
}
#pragma mark - Singleton methods
+ (ProductDataManager *)sharedManager
{
    static ProductDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ProductDataManager alloc] init];
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
    //请求分类信息回调
    if ([downloader.purpose isEqualToString:kGetCategoryDownloadKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSArray *valueArray = [dict objectForKey:@"foodCategory"];
            [[NSNotificationCenter defaultCenter]postNotificationName:kGetCategoryNotification object:valueArray];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取分类失败,请稍后再试";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    //请求某一分类下的商品信息回调
    if ([downloader.purpose isEqualToString:kGetCategoryFoodDownloadKedy])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSArray *valueArray = [dict objectForKey:@"foods"];
            [[NSNotificationCenter defaultCenter]postNotificationName:kGetCategoryFoodNotification object:valueArray];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取商品失败,请稍后再试";
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
