//
//  CourierTableViewCell.m
//  pj_for_u
//
//  Created by MiY on 15/8/25.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "CourierTableViewCell.h"
#import "CourierSubTableViewCell.h"

@interface CourierTableViewCell ()


@end


@implementation CourierTableViewCell

- (IBAction)callUserPhone
{
    self.callUsersPhone();
}

- (IBAction)changeOrderStatus
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [dict setObject:self.itsIndexPath forKey:@"indexPath"];
    [dict setObject:self.togetherId.text forKey:@"togetherId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdminChangeOrderStatusNotification object:dict];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourierSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourierSubTableViewCell"
                                                                    forIndexPath:indexPath];

    NSDictionary *dict = self.orderList[indexPath.row];
    
    NSString *isDiscount = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isDiscount"]];
    if ([isDiscount isEqualToString:@"1"]) {
        cell.price.text = [NSString stringWithFormat:@"¥%@", [dict objectForKey:@"discountPrice"]];
    } else {
        cell.price.text = [NSString stringWithFormat:@"¥%@", [dict objectForKey:@"price"]];
    }
    
    cell.orderCount.text = [NSString stringWithFormat:@"×%@", [dict objectForKey:@"orderCount"]];
    cell.foodName.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"foodName"]];
    cell.specialName.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"specialName"]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)awakeFromNib {
    //register cell
    UINib *nib = [UINib nibWithNibName:@"CourierSubTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"CourierSubTableViewCell"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
