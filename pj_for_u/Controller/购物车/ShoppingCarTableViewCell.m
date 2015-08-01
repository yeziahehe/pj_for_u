//
//  ShoppingCarTableViewCell.m
//  HDemo
//
//  Created by 缪宇青 on 15/8/1.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import "ShoppingCarTableViewCell.h"
@interface ShoppingCarTableViewCell()
@property (strong, nonatomic) IBOutlet UIView *amountView;


@end
@implementation ShoppingCarTableViewCell

- (void)loadSubView
{
    [[self.amountView layer] setCornerRadius:5];
    [[self.amountView layer] setBorderWidth:0.5];
    [[self.amountView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
}
- (void)awakeFromNib {
    // Initialization code
    [self loadSubView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
