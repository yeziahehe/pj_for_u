//
//  MyOrderTableViewCell.m
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderTableViewCell.h"
#import "MyOrderInsideTableViewCell.h"

@interface MyOrderTableViewCell ()

@end

@implementation MyOrderTableViewCell

- (void)awakeFromNib {
    self.canBeSelected = YES;
    
    //左右两个按钮增加圆角边框
    CALayer *layer = [self.leftButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.leftButton.layer.masksToBounds = YES;
    self.leftButton.layer.cornerRadius = 2.5f;
    
    CALayer *layer1 = [self.rightButton layer];
    layer1.borderColor = [[UIColor darkGrayColor] CGColor];
    layer1.borderWidth = 1.f;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.layer.cornerRadius = 2.5f;
    
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"MyOrderInsideTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderInsideTableViewCell"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//以下两个按钮事件发送同一个通知，因为本质一样
- (IBAction)leftButtonAction
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setObject:self.itsIndexPath forKey:@"indexPath"];
    [dict setObject:self.leftButton.currentTitle forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCilckOrderButtonNotification object:dict];
}

- (IBAction)rightButtonAction
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setObject:self.itsIndexPath forKey:@"indexPath"];
    [dict setObject:self.rightButton.currentTitle forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCilckOrderButtonNotification object:dict];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderInsideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderInsideTableViewCell"
                                                                       forIndexPath:indexPath];
    
    NSDictionary *smallDictionary = self.smallOrders[indexPath.row];
    
    cell.image.cacheDir = kUserIconCacheDir;
    [cell.image aysnLoadImageWithUrl:[smallDictionary objectForKey:@"imageUrl"] placeHolder:@"icon_user_default.png"];
    cell.nameLabel.text = [smallDictionary objectForKey:@"name"];
    
    NSString *realPriceType;
    NSString *isDiscount = [NSString stringWithFormat:@"%@", [smallDictionary objectForKey:@"isDiscount"]];
    if ([isDiscount isEqualToString:@"1"]) {
        realPriceType = @"discountPrice";
    } else {
        realPriceType = @"price";
    }
    
    cell.price.text = [NSString stringWithFormat:@"%@", [smallDictionary objectForKey:realPriceType]];
    cell.orderConut.text = [NSString stringWithFormat:@"%@", [smallDictionary objectForKey:@"orderCount"]];
    cell.message.text = [NSString stringWithFormat:@"%@", [smallDictionary objectForKey:@"message"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.smallOrders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.canBeSelected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushToMyOrderDetailNotification object:self.itsIndexPath];
    }
}

@end
