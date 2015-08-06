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

- (UIView *)backGrayView
{
    if (!_backGrayView) {
        _backGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 140.f)];
        _backGrayView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(removeBackGrayView)];
        singleTap.numberOfTapsRequired = 1;
        [_backGrayView addGestureRecognizer:singleTap];
        [self.contentView addSubview:_backGrayView];
        _backGrayView.hidden = YES;
    }
    return _backGrayView;
}

- (void)removeBackGrayView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveBackGrayViewNotification
                                                        object:self.shoppingId];
}

- (void)loadSubView
{
    [[self.amountView layer] setCornerRadius:5];
    [[self.amountView layer] setBorderWidth:0.5];
    [[self.amountView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
}
- (void)awakeFromNib {
    // Initialization code
    [self loadSubView];
//    self.darkGreyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    self.darkGreyView.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.5];
//    self.darkGreyView.hidden = YES;
//    [self addSubview:self.darkGreyView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)minusButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kMinusShoppingAmountNotification object:self.shoppingId];
}
- (IBAction)plusButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kPlusShoppingAmountNotification object:self.shoppingId];
}

@end
