//
//  ProInfoView.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProInfoView.h"
#import "ChooseCategoryView.h"

@interface ProInfoView ()
@property(strong,nonatomic)UIView *background;
@property(strong,nonatomic)ChooseCategoryView *chooseCategoryView;
@end

@implementation ProInfoView

#pragma mark - 懒加载
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

-(void)removeSubViews{
    if (self.chooseCategoryView) {
        CGFloat height = self.chooseCategoryView.frame.size.height;
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [self.chooseCategoryView removeFromSuperview];
                                 self.chooseCategoryView = nil;
                             }
                         }];
        [self.background removeFromSuperview];

    }
}
#pragma mark - UIView Methods
-(void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSubViews) name:kSuccessAddingToCarNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSubViews) name:kSuccessBuyNowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeSubViews) name:kRemoveChooseCategoryViewNotification object:nil];

    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - IBAction Methods
- (IBAction)showChooseDetail:(id)sender {
    self.chooseCategoryView = [[[NSBundle mainBundle]loadNibNamed:@"ChooseCategoryView" owner:self options:nil]lastObject];
    //传递参数
    self.chooseCategoryView.doneButton.hidden = YES;
    self.chooseCategoryView.proInfo = self.proInfo;
    CGFloat height = self.chooseCategoryView.frame.size.height;
    [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
    [self.window addSubview:self.background];
    [self.window addSubview:self.chooseCategoryView];
    [UIView animateWithDuration:0.2 animations:^{
        [self.chooseCategoryView setFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, height)];
    }];

}

#pragma mark - Set Methods
-(void)setProInfo:(ProductionInfo *)proInfo{
    _proInfo = proInfo;
}
@end
