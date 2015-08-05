//
//  ProInfoView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProInfoView.h"

@interface ProInfoView ()
@property(strong,nonatomic)UIView *background;
@end

@implementation ProInfoView

#pragma mark - Initialize Methods
- (UIView *)background
{
    if (!_background) {
        _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _background.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(removeSubViews)];
        singleTap.numberOfTapsRequired = 1;
        [_background addGestureRecognizer:singleTap];
    }
    return _background;
}

#pragma mark - UIView Methods
-(void)awakeFromNib{
    [super awakeFromNib];
    
}

#pragma mark - IBAction Methods
- (IBAction)showChooseDetail:(id)sender {
    
}

@end
