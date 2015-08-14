//
//  HomeContainView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeContainView.h"
#import "HomeModuleModel.h"
#import "CategoryInfo.h"
#import "GeneralProductViewController.h"

#define kGetModuleTypeDownloaderKey     @"GetModuleTypeDownloaderKey"

@interface HomeContainView ()
@property (nonatomic, strong) NSMutableArray *homeModuleArray;
@property (nonatomic, strong) HomeModuleModel *homeModuleModel;
@property(strong,nonatomic)NSMutableArray *allCategories;

@end

@implementation HomeContainView
@synthesize homeModuleArray,homeModuleButtons,homeModuleModel;

#pragma mark - Private Methods
- (void)loadHomeModuleIsOpen
{
    if (self.homeModuleArray.count > 0) {
        int i = 0;
        for (UIButton *button in self.homeModuleButtons) {
            self.homeModuleModel = [self.homeModuleArray objectAtIndex:i];
            if ([self.homeModuleModel.isOpen isEqualToString:@"1"]) {
                [button addTarget:self action:@selector(OpenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [button addTarget:self action:@selector(noOpenButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            }
            i++;
        }
    }
    else {
        for (UIButton *button in self.homeModuleButtons) {
            [button addTarget:self action:@selector(noOpenButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)requestForHomeModule
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetModuleTypeUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    NSLog(@"%@",kCampusId);
    [dict setObject:kCampusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetModuleTypeDownloaderKey];
}

-(void)getCategoriesWithCampusId:(NSString *)campusId{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetCategoryUrl];
    //传递参数存放的字典
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:campusId forKey:@"campusId"];
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSArray *valueArray = [responseObject objectForKey:@"foodCategory"];
        self.allCategories = [NSMutableArray arrayWithCapacity:0];
        for(NSDictionary *valueDict in valueArray)
        {
            CategoryInfo *pi = [[CategoryInfo alloc]initWithDict:valueDict];
            [self.allCategories addObject:pi];
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}
#pragma mark - IBAction Methods
- (void)noOpenButtonClicked
{
    [[YFProgressHUD sharedProgressHUD] showWithMessage:@"该模块尚未开通，敬请期待..." customView:nil hideDelay:3.f];
}

-(void)OpenButtonClicked:(UIButton *)button
{
    for(CategoryInfo *ci in self.allCategories){
        NSInteger serial = [ci.serial intValue];
        if (button.tag == serial) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kButtonCategoryNotfication object:ci];
        }
    }
}
#pragma mark - UIView methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self requestForHomeModule];
    [self getCategoriesWithCampusId:kCampusId];
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
            //设置首页模块的开通属性
            [self loadHomeModuleIsOpen];
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
