//
//  IndividualSubViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualSubViewController.h"

@interface IndividualSubViewController ()

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation IndividualSubViewController

- (void)updateIndividualInfo
{
    //[[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"保存中..."];
    //    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSaveIndividualInfo];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:@"18888888888" forKey:@"phone"];
    [dict setObject:self.individualInfo.nickname forKey:@"nickname"];
    
    if ([self.individualInfo.sex isEqualToString:@"男"]) {
        [dict setObject:@"0" forKey:@"sex"];
    } else {
        [dict setObject:@"1" forKey:@"sex"];
    }
    
    
    [dict setObject:self.individualInfo.academy forKey:@"academy"];
    [dict setObject:self.individualInfo.qq forKey:@"qq"];
    [dict setObject:self.individualInfo.weiXin forKey:@"weiXin"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:@"saveIndividualInfo"];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    self.individualInfo.infos[self.indexPath.section + 1] = self.textField.text;
    
    switch (self.indexPath.section) {
        case 0:
            self.individualInfo.nickname = self.textField.text;
            break;
        case 1:
            self.individualInfo.sex = self.textField.text;
            break;
        case 2:
            self.individualInfo.academy = self.textField.text;
            break;
        case 3:
            self.individualInfo.qq = self.textField.text;
            break;
        case 4:
            self.individualInfo.weiXin = self.textField.text;
            break;
        default:
            break;
    }
    
    [self updateIndividualInfo];
    
    return YES;
}

- (void)rightItemTapped
{
    [self textFieldShouldReturn:self.textField];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:self.navigationTitle];
    
    self.textField.text = self.textFieldString;
    [self.textField becomeFirstResponder];
    
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];
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
    NSDictionary *dict = [str JSONValue];
    
    if ([downloader.purpose isEqualToString:@"saveIndividualInfo"]) {
        if ([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = @"保存成功！";
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];
        } else {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSString *message = @"保存失败！";
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];

        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


@end
