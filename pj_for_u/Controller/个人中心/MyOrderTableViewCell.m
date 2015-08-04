//
//  MyOrderTableViewCell.m
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderTableViewCell.h"
#import "MyOrderInsideTableViewCell.h"

@implementation MyOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
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
    
    UINib *nib = [UINib nibWithNibName:@"MyOrderInsideTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderInsideTableViewCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toPay:(UIButton *)sender
{
    
}

- (IBAction)cancelOrder:(UIButton *)sender
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderInsideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderInsideTableViewCell"];
    
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

@end
