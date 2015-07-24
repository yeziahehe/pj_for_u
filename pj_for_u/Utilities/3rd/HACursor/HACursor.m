//
//  HACursor.m
//  HAScrollNavBar
//
//  Created by haha on 15/7/6.
//  Copyright (c) 2015年 haha. All rights reserved.
//

#import "HACursor.h"
#import "HAScrollNavBar.h"
#import "UIView+Extension.h"
#import "UIColor+RGBA.h"
#import "HAItemManager.h"

#define navLineHeight 6
#define StaticItemIndex 3
#define SortItemViewY -360
#define SortItemViewMoveToY -70
#define HAScrollItemIndex @"index"
#define defBackgroundColor [UIColor whiteColor]

@interface HACursor()<UIScrollViewDelegate>

@property (nonatomic, strong) HAScrollNavBar *scrollNavBar;

@property (nonatomic, assign) BOOL isDrag;
@property (nonatomic, assign) BOOL isRefash;
@property (nonatomic, assign) CGFloat oldOffset;
@property (nonatomic, assign) CGFloat navBarH;
@property (nonatomic, assign) NSInteger oldBtnIndex;
@end

@implementation HACursor

#pragma -mark 懒加载
- (void)setPageViews:(NSMutableArray *)pageViews{
    _pageViews = pageViews;
    self.scrollNavBar.pageViews = pageViews;
}

- (HAScrollNavBar *)scrollNavBar{
    if (!_scrollNavBar) {
        _scrollNavBar = [[HAScrollNavBar alloc]init];
        _scrollNavBar.backgroundColor = [UIColor redColor];
        _scrollNavBar.delegate = self;
    }
    return _scrollNavBar;
}

#pragma -mark 属性配置
- (void)setRootScrollView:(UIScrollView *)rootScrollView{
    _rootScrollView = rootScrollView;
    self.scrollNavBar.rootScrollView = rootScrollView;
    [self addSubview:rootScrollView];
    [self insertSubview:rootScrollView atIndex:0];
    CGRect rect = self.frame;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    if (self.navBarH == 0 ) {
        self.navBarH = h;
        h = h + self.rootScrollView.height;
    }
    CGRect frameChanged = CGRectMake(x, y, w, h);
    [self setFrame:frameChanged];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:[UIColor clearColor]];
    self.scrollNavBar.backgroundColor = backgroundColor;
}

- (void)setTitles:(NSArray *)titles{
    BOOL isHaveSameTitle = [self checkisHaveSameItem:titles];
    NSAssert(!isHaveSameTitle, @"错误！！！不可以包含相同的标题");
    _titles = titles;

    [[HAItemManager shareitemManager] setScrollNavBar:self.scrollNavBar];
    [[HAItemManager shareitemManager] setItemTitles:(NSMutableArray *)titles];
    
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor{
    _titleNormalColor = titleNormalColor;
    self.scrollNavBar.titleNormalColor = titleNormalColor;
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor{
    _titleSelectedColor = titleSelectedColor;
    self.scrollNavBar.titleSelectedColor = titleSelectedColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage{
    _backgroundImage = backgroundImage;
    self.scrollNavBar.backgroundImage = backgroundImage;
}

- (void)setIsGraduallyChangColor:(BOOL)isGraduallyChangColor{
    _isGraduallyChangColor = isGraduallyChangColor;
    self.scrollNavBar.isGraduallyChangColor = isGraduallyChangColor;
}

- (void)setIsGraduallyChangFont:(BOOL)isGraduallyChangFont{
    _isGraduallyChangColor = isGraduallyChangFont;
    self.scrollNavBar.isGraduallyChangFont = isGraduallyChangFont;
}

- (void)setMinFontSize:(NSInteger)minFontSize{
    _minFontSize = minFontSize;
    self.scrollNavBar.minFontSize = minFontSize;
}

- (void)setMaxFontSize:(NSInteger)maxFontSize{
    _maxFontSize = maxFontSize;
    self.scrollNavBar.maxFontSize = maxFontSize;
}

#pragma -mark 初始化
- (void)setup{
    [self addSubview:self.scrollNavBar];
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    if (!self.backgroundColor) {
        self.backgroundColor = defBackgroundColor;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIndex:) name:HAScrollItemIndex object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    //不显示排序按钮的布局
    CGFloat scrollX = 0;
    CGFloat scrollY = 0;
    CGFloat scrollH = 45;
    self.navBarH = scrollH;
    CGFloat scrollW = self.width;
    self.scrollNavBar.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);
    
    CGFloat rootScrollX = 0;
    CGFloat rootScrollY = self.navBarH;
    CGFloat rootScrollW = self.rootScrollView.width;
    CGFloat rootScrollH = self.rootScrollView.height;
    self.rootScrollView.frame = CGRectMake(rootScrollX, rootScrollY, rootScrollW, rootScrollH);
}

#pragma -mark 业务逻辑
- (CGFloat)tranlateXWithButtonIndex:(NSInteger)index{
    CGFloat offset = 0.0;
    NSInteger detal = self.scrollNavBar.itemKeys.count - StaticItemIndex - 1;
    if (self.titles.count * self.scrollNavBar.itemW > self.scrollNavBar.width) {
        CGFloat detalX = 0;
        if (index < StaticItemIndex) {
            offset = index * self.scrollNavBar.itemW;
        }else if(index > detal){
            detalX = self.scrollNavBar.contentSize.width - self.scrollNavBar.width;
            offset = (index - detal + StaticItemIndex - 2) * self.scrollNavBar.itemW ;
        }else{
            detalX = self.scrollNavBar.currectItem.centerX - self.centerX;
            offset = self.centerX;
        }
    }else{
        offset = index * self.scrollNavBar.itemW;
    }
    return offset;
}

- (CGFloat)getNavLineOffset{
    CGFloat offset = 0;
    if (self.isRefash) {
        offset = self.oldOffset;
        self.isRefash = NO;
    }else{
        offset = [self tranlateXWithButtonIndex:self.scrollNavBar.oldItem.tag];
    }
    return offset;
}

- (BOOL)checkisHaveSameItem:(NSArray *)titles{
    for (int i = 0; i < titles.count; i++) {
        NSString *title1 = titles[i];
        for (int j = 0; j < titles.count; j++) {
            NSString *title2 = titles[j];
            if (j != i && [title1 isEqualToString:title2]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma -mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.isDrag = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isDrag) {
        CGRect rect = [self.scrollNavBar.currectItem convertRect:self.scrollNavBar.currectItem.frame toView:self];
        self.oldOffset = rect.origin.x - (self.oldBtnIndex * self.scrollNavBar.itemW);
        self.isRefash = YES;
    }
}

@end

