//
//  YFRootBlurViewManager.m
//  BOEFace
//
//  Created by 叶帆 on 15/7/16.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import "YFRootBlurViewManager.h"

@interface YFRootBlurView : UIView

@property (nonatomic, strong) UIImageView *blurBGImageView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation YFRootBlurView

@synthesize blurBGImageView,contentView;

#pragma mark - UIView methods

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        blurBGImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:blurBGImageView];
    }
    return self;
}

#pragma mark - UIResponder methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[YFRootBlurViewManager sharedManger] hideBlurView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopNotification" object:nil];
}

@end

@interface YFRootBlurViewManager ()

@property (nonatomic, strong) YFRootBlurView *blurView;

@end

@implementation YFRootBlurViewManager

@synthesize blurView;

#pragma mark - Sigleton methods
- (id)init
{
    if(self = [super init])
    {
        blurView = [[YFRootBlurView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blurView.backgroundColor = [UIColor clearColor];
        [[[UIApplication sharedApplication] keyWindow] addSubview:blurView];
        blurView.alpha = 0;
    }
    return self;
}

+ (YFRootBlurViewManager *)sharedManger
{
    static YFRootBlurViewManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YFRootBlurViewManager alloc] init];
    });
    return manager;
}

#pragma mark - Public methods

- (void)showWithBlurImage:(UIImage *)image contentView:(UIView *)contentView position:(CGPoint)position
{
    //替换当前的模糊底图
    self.blurView.blurBGImageView.image = image;
    //替换当前的contengview
    if(self.blurView.contentView)
    {
        [self.blurView.contentView removeFromSuperview];
        self.blurView.contentView = nil;
    }
    self.blurView.contentView = contentView;
    [self.blurView addSubview:contentView];
    if(!CGPointEqualToPoint(position, CGPointZero))
    {
        CGRect rect = contentView.frame;
        rect.origin.x = position.x;
        rect.origin.y = position.y;
        contentView.frame = rect;
    }
    else
    {
        contentView.center = CGPointMake(self.blurView.frame.size.width/2, self.blurView.frame.size.height/2.f);
    }
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.blurView];
    //添加显示动画
    CATransition *fadeTransition = [CATransition animation];
    fadeTransition.duration = 0.2f;
    fadeTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fadeTransition.type = kCATransitionFade;
    [self.blurView.layer addAnimation:fadeTransition forKey:nil];
    self.blurView.alpha = 1.f;
    //添加弹出动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.;
    opacityAnimation.toValue = @1.;
    opacityAnimation.duration = 0.1f;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D startingScale = CATransform3DScale(self.blurView.contentView.layer.transform, 0, 0, 0);
    CATransform3D overshootScale = CATransform3DScale(self.blurView.contentView.layer.transform, 1.05, 1.05, 1.0);
    CATransform3D undershootScale = CATransform3DScale(self.blurView.contentView.layer.transform, 0.98, 0.98, 1.0);
    CATransform3D endingScale = self.blurView.contentView.layer.transform;
    
    NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
    NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
    NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
    [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
    [keyTimes addObject:@1.0f];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    scaleAnimation.values = scaleValues;
    scaleAnimation.keyTimes = keyTimes;
    scaleAnimation.timingFunctions = timingFunctions;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.duration = 0.2f;
    
    [self.blurView.contentView.layer addAnimation:animationGroup forKey:nil];
}

- (void)hideBlurView
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1.;
    opacityAnimation.toValue = @0.;
    opacityAnimation.duration = 0.2f;
    [self.blurView.layer addAnimation:opacityAnimation forKey:nil];
    
    CATransform3D transform = CATransform3DScale(self.blurView.contentView.layer.transform, 0, 0, 0);
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:self.blurView.contentView.layer.transform];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    scaleAnimation.duration = 0.2f;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[opacityAnimation, scaleAnimation];
    animationGroup.duration = 0.2f;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.blurView.contentView.layer addAnimation:animationGroup forKey:nil];
    
    self.blurView.alpha = 0;
}


@end
