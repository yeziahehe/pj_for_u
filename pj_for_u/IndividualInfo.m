//
//  IndividualInfo.m
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualInfo.h"



@implementation IndividualInfo

- (instancetype)initWithimgUrl:(NSString *)imgUrl
                      nickname:(NSString *)nickname
                           sex:(NSString *)sex
                       academy:(NSString *)academy
                            qq:(NSString *)qq
                        weiXin:(NSString *)weiXin
{
    self = [super init];

    if (self) {
        _imgUrl = imgUrl;
        _nickname = nickname;
        _sex = sex;
        _academy = academy;
        _qq = qq;
        _weiXin = weiXin;
    }

    return self;
}

- (NSMutableArray *)infos
{
    if (!_infos) {
        _infos = [[NSMutableArray alloc] initWithCapacity:6];
    }
    return _infos;
}

- (void)requestForIndividualInfo
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
//    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kIndividualInfoUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:@"18888888888" forKey:@"phone"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kIndividualInfo];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kIndividualInfo])
    {
        if ([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSDictionary *value = [dict objectForKey:@"userInfo"];
            
            if ([value objectForKey:@"imgUrl"] == nil) {
                self.imgUrl = @"未填写";
            } else {
                self.imgUrl = [NSString stringWithFormat:@"%@", [value objectForKey:@"imgUrl"]];
            }
            if ([value objectForKey:@"nickname"] == nil) {
                self.nickname = @"未填写";
            } else {
                self.nickname = [NSString stringWithFormat:@"%@", [value objectForKey:@"nickname"]];
            }
            if ([value objectForKey:@"sex"] == nil) {
                self.sex = @"未填写";
            } else {
                NSString *mySex = [NSString stringWithFormat:@"%@", [value objectForKey:@"sex"]];
                if ([mySex isEqualToString:@"0"]) {
                    self.sex = @"男";
                } else {
                    self.sex = @"女";
                }
            }
            if ([value objectForKey:@"academy"] == nil) {
                self.academy = @"未填写";
            } else {
                self.academy = [NSString stringWithFormat:@"%@", [value objectForKey:@"academy"]];
            }
            if ([value objectForKey:@"qq"] == nil) {
                self.qq = @"未填写";
            } else {
                self.qq = [NSString stringWithFormat:@"%@", [value objectForKey:@"qq"]];
            }
            if ([value objectForKey:@"weiXin"] == nil) {
                self.weiXin = @"未填写";
            } else {
                self.weiXin = [NSString stringWithFormat:@"%@", [value objectForKey:@"weiXin"]];
            }
            
            [self.infos addObject:self.imgUrl];
            [self.infos addObject:self.nickname];
            [self.infos addObject:self.sex];
            [self.infos addObject:self.academy];
            [self.infos addObject:self.qq];
            [self.infos addObject:self.weiXin];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadIndividual" object:nil];
            
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
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
