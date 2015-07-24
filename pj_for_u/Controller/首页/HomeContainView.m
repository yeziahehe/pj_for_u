//
//  HomeContainView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeContainView.h"
#import "HomeModuleModel.h"
#define kGetModuleTypeDownloaderKey     @"GetModuleTypeDownloaderKey"

@interface HomeContainView ()
@property (nonatomic, strong) NSMutableArray *homeModuleArray;
@end

@implementation HomeContainView
@synthesize homeModuleArray;

#pragma mark - Private Methods
- (void)requestForHomeModule
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetModuleTypeUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetModuleTypeUrl];
}

#pragma mark - UIView methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self requestForHomeModule];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetModuleTypeDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.homeModuleArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"homeCategory"];
            for (NSDictionary *valueDict in valueArray) {
                HomeModuleModel *hmm = [[HomeModuleModel alloc]initWithDict:valueDict];
                [self.homeModuleArray addObject:hmm];
            }
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
