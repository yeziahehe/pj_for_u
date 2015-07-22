//
//  UIImage+YFAdditions.m
//  V2EX
//
//  Created by 叶帆 on 14-9-24.
//  Copyright (c) 2014年 yefan. All rights reserved.
//

#import "UIImage+YFAdditions.h"

@implementation UIImage (YFAdditions)

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
