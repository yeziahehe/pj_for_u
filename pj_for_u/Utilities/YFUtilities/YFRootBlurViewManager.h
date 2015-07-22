//
//  YFRootBlurViewManager.h
//  BOEFace
//
//  Created by 叶帆 on 15/7/16.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

/*
 该类用户控制keywindow最前面的view的显示
 */

#import <UIKit/UIKit.h>

@interface YFRootBlurViewManager : UIView

+ (YFRootBlurViewManager *)sharedManger;

/**
 使用抖动动画居中覆盖显示于keywindow之上
	@param image 需要显示的view的底图（可加入模糊处理）
	@param contentView 需要显示的内容view
 @param position 需要显示的内容view的位置，如果值是CGPointZero时，会居中显示
	@returns nil
 */
- (void)showWithBlurImage:(UIImage *)image
              contentView:(UIView *)contentView
                 position:(CGPoint)position;

/**
	使用抖动动画隐藏keywindow之上的覆盖view
	@returns nil
 */
- (void)hideBlurView;

@end
