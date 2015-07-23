//
//  MemberDataManager.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MemberDataManager.h"

@implementation MemberDataManager
@synthesize loginMember;

#pragma mark - Public Methods
- (BOOL)isLogin
{
    if(self.loginMember.phone.length > 0 && self.loginMember.password.length > 0)
        return YES;
    else
        return NO;
}

- (void)logout
{
    //清空用户信息
    self.loginMember.phone = nil;
    self.loginMember.password = nil;
    self.loginMember.type = nil;
    [self saveLoginMemberData];
    [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"退出成功" hideDelay:4.0f];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangeNotification object:nil];
}

- (void)saveLoginMemberData
{
    //保存登录用户信息
    NSData *memberData = [NSKeyedArchiver archivedDataWithRootObject:self.loginMember];
    NSString *userDataFilePath = [DOCUMENTS_FOLDER stringByAppendingPathComponent:kLoginUserDataFile];
    [memberData writeToFile:userDataFilePath atomically:NO];
}

- (void)loginWithAccountName:(NSString *)phone password:(NSString *)password
{
    if(nil == phone)
        phone = @"";
    if(nil == password)
        password = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kLoginUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phone"];
    [dict setObject:password forKey:@"password"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kLoginDownloaderKey];
}

#pragma mark - Singleton methods
- (id)init
{
    if(self = [super init])
    {
        //读取本地用户信息
        NSString *userDataFilePath = [DOCUMENTS_FOLDER stringByAppendingPathComponent:kLoginUserDataFile];
        self.loginMember = [NSKeyedUnarchiver unarchiveObjectWithFile:userDataFilePath];
        if(nil == loginMember)
            loginMember = [[Member alloc] init];
    }
    return self;
}

+ (MemberDataManager *)sharedManager
{
    static MemberDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MemberDataManager alloc] init];
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
    if ([downloader.purpose isEqualToString:kLoginDownloaderKey])
    {
        NSDictionary *dict = [str JSONValue];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            self.loginMember = [Member memberWithDict:dict];
            [[MemberDataManager sharedManager] saveLoginMemberData];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginResponseNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangeNotification object:nil];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"登录失败";
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginResponseNotification object:message];
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}
@end
