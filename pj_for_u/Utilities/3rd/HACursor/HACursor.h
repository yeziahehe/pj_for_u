//
//  HACursor.h
//  HAScrollNavBar
//
//  Created by haha on 15/7/6.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HACursor : UIView

@property (nonatomic, weak) UIScrollView *rootScrollView;

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;

@property (nonatomic, assign) BOOL isGraduallyChangColor;
@property (nonatomic, assign) BOOL isGraduallyChangFont;
@property (nonatomic, assign) NSInteger minFontSize;
@property (nonatomic, assign) NSInteger maxFontSize;
@property (nonatomic, assign) NSInteger defFontSize;
@end
