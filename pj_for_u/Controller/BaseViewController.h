//
//  BaseViewController.h
//  SJFood
//
//  Created by 叶帆 on 14/11/25.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

/**
 *  该类为所有页面的基类方法，加入了UINavigationBar 左右item的定义
 */
#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

/**
 *  NavigationItem 左边itemclick事件
 */
- (void)leftItemTapped;
/**
 *  NavigationItem 右边item click事件
 */
- (void)rightItemTapped;
/**
 *  NavigationItem 中间item click事件
 */
- (void)extraItemTapped;
/**
 设置基类的NavigationBar的leftItem/rightItem, item的title和image不可同时为nil。
 当title存在的时候用title设置，title不存在的时候用image设置
 @param title leftItem的title
 @param imageName leftItem的imageName
 */
- (void)setLeftNaviItemWithTitle:(NSString *)title imageName:(NSString *)imageName;
- (void)setRightNaviItemWithTitle:(NSString *)title imageName:(NSString *)imageName;

/**
 设置NavigationBar的title
 @param title 需要设置的title
 */
- (void)setNaviTitle:(NSString *)title;

- (void)setNaviImageTitle:(NSString *)imageName;

@end
