//
//  HomeActivityTableView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeActivityTableView.h"
#import "HomeActivityTableViewCell.h"

@interface HomeActivityTableView ()
@property (nonatomic, strong) NSMutableArray *imageUrlArray;


@end
@implementation HomeActivityTableView

#pragma mark - Private Methods
- (void)reloadWithActivityImages:(NSMutableArray *)activityImagesArray
{
    self.imageUrlArray = [NSMutableArray arrayWithArray:activityImagesArray];
    [self.activityTableview reloadData];
}

#pragma mark - UIView Methods
- (void)awakeFromNib
{
    [super awakeFromNib];
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
    NSString *imgUrl = [[self.imageUrlArray objectAtIndex:indexPath.row] objectForKey:@"homeImage"];
    cell.activityImageView.cacheDir = kUserIconCacheDir;
    [cell.activityImageView aysnLoadImageWithUrl:imgUrl placeHolder:@"home_image_default.png"];
    
    cell.foodId = [[self.imageUrlArray objectAtIndex:indexPath.row] objectForKey:@"foodId"];
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeActivityTableViewCell *cell = (HomeActivityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    self.pushToProductDetail(cell.foodId);
    
}

@end
