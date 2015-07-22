//
//  UIImage+YFAdditions.h
//  V2EX
//
//  Created by 叶帆 on 14-9-24.
//  Copyright (c) 2014年 yefan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YFAdditions)

/**
 将UIColor转化成UIImage
 @param color 需要转变的UIColor
 @param size  需要转变的大小
 @return UIImage
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
