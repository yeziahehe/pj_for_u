//
//  HomeActivityTableView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeActivityTableView.h"
#import "HomeActivityTableViewCell.h"
#define kGetActivityImagesDownloaderKey  @"GetActivityImagesDownloaderKey"

@interface HomeActivityTableView ()
@property (nonatomic, strong) NSMutableArray *imageUrlArray;

@end
@implementation HomeActivityTableView

- (void)requestForImages
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetActivityImageUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetActivityImagesDownloaderKey];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self requestForImages];
    self.activityTableview.delegate = self;
    self.activityTableview.dataSource = self;
    self.activityTableview.scrollEnabled = NO;

}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageUrlArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"HomeActivityTableViewCell";
    HomeActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"HomeActivityTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
    NSString *imgUrl = [self.imageUrlArray objectAtIndex:indexPath.row];
    cell.activityImageView.cacheDir = kUserIconCacheDir;
    [cell.activityImageView aysnLoadImageWithUrl:imgUrl placeHolder:@"home_image_default.png"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetActivityImagesDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            self.imageUrlArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"food"];
            for (NSDictionary *valueDict in valueArray) {
                NSString *lm = [valueDict objectForKey:@"imgUrl"];
                [self.imageUrlArray addObject:lm];
            }
           // [self reloadWithProductAds:self.imageUrlArray];
            [self.activityTableview reloadData];
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
