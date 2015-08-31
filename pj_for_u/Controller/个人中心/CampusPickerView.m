//
//  CampusPickerView.m
//  pj_for_u
//
//  Created by 牛严 on 15/7/28.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "CampusPickerView.h"
#import "LocationModel.h"
#import "CampusMoel.h"

#define kGetLocationDownloaderKey       @"GetLocationDownloaderKey"

@interface CampusPickerView ()
@property (nonatomic, strong) NSMutableArray *cityArray;
@property (nonatomic, strong) NSMutableArray *schoolArray;
@property (nonatomic, strong) LocationModel *locationModel;
@property (nonatomic, strong) CampusMoel *campusModel;
@end

@implementation CampusPickerView

#pragma mark - Private Methods
- (void)requestForLocationInfo
{
    [self.doneButton setEnabled:NO];
    
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载校区信息"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress, kLocationUrl];
    [[YFDownloaderManager sharedManager] requestDataByGetWithURLString:url
                                                              delegate:self
                                                               purpose:kGetLocationDownloaderKey];
}

#pragma mark - UIView Methods
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.campusPickerView.delegate = self;
    self.campusPickerView.dataSource = self;
    [self requestForLocationInfo];
    [self.campusPickerView selectRow:0 inComponent:0 animated:NO];
    [self.campusPickerView selectRow:0 inComponent:1 animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return self.cityArray.count;
            
        case 1:
            return self.schoolArray.count;
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate Methods
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{

    switch (component) {
        case 0:
        {
            UILabel *dateLabel = (UILabel *)view;
            dateLabel = [[UILabel alloc] init];
            dateLabel.font = [UIFont fontWithName:nil size:15];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
            
            self.locationModel = [self.cityArray objectAtIndex:row];
            [dateLabel setText:self.locationModel.cityName];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            return dateLabel;
        }
            break;
            
        case 1:
        {
            UILabel *dateLabel = [[UILabel alloc] init];
            dateLabel.font = [UIFont fontWithName:nil size:15];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
            
            if (self.schoolArray.count == 0) {
                [dateLabel setText:@"暂无数据"];
            } else {
                self.campusModel = [self.schoolArray objectAtIndex:row];
                [dateLabel setText:self.campusModel.campusName];
            }
            
            dateLabel.textAlignment = NSTextAlignmentLeft;
            return dateLabel;
        }
        default:
            break;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            self.locationModel = [self.cityArray objectAtIndex:row];
            self.schoolArray = [NSMutableArray arrayWithArray:self.locationModel.campuses];
            
            if (self.schoolArray.count > 0) {
                self.campusModel = [self.schoolArray objectAtIndex:0];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kGetFirstCampusNameWithNotification object:self.campusModel];
            //更新第二个轮子并重置
            [self.campusPickerView reloadComponent:1];
            [self.campusPickerView selectRow:0 inComponent:1 animated:NO];

        }
            break;
        case 1:
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kGetCampusNameWithNotification object:self.campusModel];
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35.0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 150.f;
            break;
        case 1:
            return 150.f;
        default:
            break;
    }
    return 0;
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetLocationDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.cityArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"campus"];
            for (NSDictionary *valueDict in valueArray) {
                LocationModel *lm = [[LocationModel alloc]initWithDict:valueDict];
                [self.cityArray addObject:lm];
                //默认
                self.locationModel = [self.cityArray objectAtIndex:0];
                self.schoolArray = [NSMutableArray arrayWithArray:self.locationModel.campuses];
                CampusMoel *cm = [self.schoolArray objectAtIndex:0];
                [self.campusPickerView reloadAllComponents];
                [[NSNotificationCenter defaultCenter]postNotificationName:kGetFirstCampusNameWithNotification object:cm];
            }
            [self.doneButton setEnabled:YES];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取校区信息失败";
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
