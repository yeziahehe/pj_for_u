//
//  SchoolSelectTableView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "SchoolSelectTableView.h"
#import "CampusMoel.h"

@interface SchoolSelectTableView ()
@property (nonatomic, strong) NSMutableArray *schoolSelectArray;
@end

@implementation SchoolSelectTableView
@synthesize schoolSelectTableView,schoolSelectArray;

#pragma mark - Public Methods
- (void)reloadWithLocationInfo:(NSMutableArray *)info
{
    self.schoolSelectArray = info;
    [self.schoolSelectTableView zeroSeparatorInset];
    self.schoolSelectTableView.tableFooterView = [UIView new];
    [self.schoolSelectTableView reloadData];
}

#pragma mark - UIView Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.schoolSelectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"SchoolSelectTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentity];
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell zeroSeparatorInset];

    CampusMoel *cm = [self.schoolSelectArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = kLightTextColor;
    cell.textLabel.text = cm.campusName;
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSchoolSelectedNotificaition object:[NSNumber numberWithInteger:indexPath.row]];
}

@end
