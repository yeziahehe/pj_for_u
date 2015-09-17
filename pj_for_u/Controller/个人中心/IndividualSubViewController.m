//
//  IndividualSubViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualSubViewController.h"
#define kUpdateUserInfoDownloaderKey        @"UpdateUserInfoDownloaderKey"

@interface IndividualSubViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textField;
@end

@implementation IndividualSubViewController
@synthesize userInfoDetailDict,textField;

- (void)requestUpdateUserInfo
{
    [self.view endEditing:YES];
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"保存中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSaveIndividualInfo];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phone"];
    [dict setObject:self.textField.text forKey:[self.userInfoDetailDict objectForKey:@"keyname"]];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kUpdateUserInfoDownloaderKey];
}

#pragma mark - Private Methods
- (void)loadSubView
{
    [self.textField becomeFirstResponder];
    [self setNaviTitle:[self.userInfoDetailDict objectForKey:@"valuename"]];
    if ([[self.userInfoDetailDict objectForKey:@"valuename"] isEqualToString:@"QQ号"])
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.text = [[MemberDataManager sharedManager].mineInfo.userInfo valueForKey:[self.userInfoDetailDict objectForKey:@"keyname"]];
}

#pragma mark - BaseViewController Methods
- (void)rightItemTapped
{
    if ([[self.userInfoDetailDict objectForKey:@"valuename"] isEqualToString:@"昵称"]) {
        if (self.textField.text.length > 8) {
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"昵称不能超过8位" hideDelay:2.f];
        }
        else {
            [self requestUpdateUserInfo];
        }
    }
    else {
        [self requestUpdateUserInfo];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];
    [self loadSubView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([downloader.purpose isEqualToString:kUpdateUserInfoDownloaderKey])
    {
        NSDictionary *dict = [str JSONValue];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"保存成功" hideDelay:2.f];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUserInfoNotificaiton object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"保存失败";
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
