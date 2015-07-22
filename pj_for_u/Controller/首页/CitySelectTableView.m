//
//  CitySelectTableView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "CitySelectTableView.h"
#import "LocationModel.h"

@interface CitySelectTableView ()
@property (nonatomic, strong) NSMutableArray *citySelectArray;
@end

@implementation CitySelectTableView
@synthesize citySelectTableView,citySelectArray;

#pragma mark - Public Methods
- (void)reloadWithLocationInfo:(NSMutableArray *)info
{
    self.citySelectArray = info;
    self.citySelectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.citySelectTableView.tableFooterView = [UIView new];
    [self.citySelectTableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.citySelectTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark - UIView Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.citySelectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"CitySelectTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentity];
        UIImageView *selectedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_select_city.png"]];
        cell.selectedBackgroundView = selectedView;
    }

    if (cell.selected) {
        cell.textLabel.textColor = [UIColor whiteColor];
    } else {
        cell.textLabel.textColor = kMainBlackColor;
    }
    
    LocationModel *lm = [self.citySelectArray objectAtIndex:indexPath.row];
    cell.textLabel.text = lm.cityName;
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCitySelectedNotificaition object:[NSNumber numberWithInteger:indexPath.row]];
}

@end
