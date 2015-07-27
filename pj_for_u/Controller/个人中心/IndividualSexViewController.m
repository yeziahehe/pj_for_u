//
//  IndividualSexViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualSexViewController.h"

@interface IndividualSexViewController ()

@property (strong, nonatomic) IBOutlet UIButton *manButton;
@property (strong, nonatomic) IBOutlet UIButton *womanButton;



@end

@implementation IndividualSexViewController

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

- (IBAction)selectMan:(UIButton *)sender
{
    [self.manButton setImage:[UIImage imageNamed:@"full_choice.png"] forState:UIControlStateNormal];
    [self.womanButton setImage:[UIImage imageNamed:@"empty_choice.png"] forState:UIControlStateNormal];
    self.sex = @"男";
}

- (IBAction)selectWoman:(UIButton *)sender
{
    [self.womanButton setImage:[UIImage imageNamed:@"full_choice.png"] forState:UIControlStateNormal];
    [self.manButton setImage:[UIImage imageNamed:@"empty_choice.png"] forState:UIControlStateNormal];
    self.sex = @"女";
}

- (void)rightItemTapped
{
    self.individualInfo.infos[2] = self.sex;
    self.individualInfo.sex = self.sex;
    [self updateIndividualInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"性别"];
    
    [self setRightNaviItemWithTitle:@"保存" imageName:nil];
    
    self.manButton.userInteractionEnabled = YES;
    
    if ([self.individualInfo.sex isEqualToString:@"男"]) {
        [self.manButton setImage:[UIImage imageNamed:@"full_choice.png"] forState:UIControlStateNormal];
        [self.womanButton setImage:[UIImage imageNamed:@"empty_choice.png"] forState:UIControlStateNormal];
    } else if ([self.individualInfo.sex isEqualToString:@"女"]) {
        [self.womanButton setImage:[UIImage imageNamed:@"full_choice.png"] forState:UIControlStateNormal];
        [self.manButton setImage:[UIImage imageNamed:@"empty_choice.png"] forState:UIControlStateNormal];
    }
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

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
